//
//  DateExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//
// https://nsdateformatter.com/

import Foundation

public enum DateFormats: Equatable {
    case standard
    case logger
    case ISO8601
    case ISO8601Z
    case ISO8601WithMilliseconds
    case ISO8601OnlyDate
    case relative
    case userFacingOnlyDate
    case userFacingOnlyTime
    case userFacingDateAndTime
    case userFacingDateAndTimeAt
    case custom(format: String)

    var formatted: String {
        switch self {
        case .standard:
            return "dd/MM/yyyy HH:mm:ss"
        case .logger:
            return "HH:mm:ss"
        case .ISO8601:
            return "yyyy-MM-dd'T'HH:mm:ssZ"
        case .ISO8601Z:
            return "yyyy-MM-dd'T'HH:mm:ss'Z'"
        case .ISO8601WithMilliseconds:
            return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .ISO8601OnlyDate:
            return "yyyy-MM-dd"
        case .userFacingOnlyDate:
            return "dd/MM/yy"
        case .userFacingOnlyTime:
            return "HH:mm"
        case .userFacingDateAndTime:
            return "dd/MM/yy HH:mm"
        case .userFacingDateAndTimeAt:
            return "user_facing_date_and_time_at".localized
        case let .custom(format: format):
            return format
        default:
            return "yyy-MM-dd"
        }
    }
}

public extension Locale {
    static var utc: Locale { .init(identifier: "UTC") }
}

public extension Date {
    func asStringWith(format: DateFormats = .ISO8601Z,
                      timeZone: TimeZone = TimeZone(abbreviation: "UTC")!,
                      locale: Locale = .utc) -> String {
        switch format {
        case .relative:
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = locale
            formatter.unitsStyle = .full

            return formatter.localizedString(for: self, relativeTo: Date())
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = format.formatted
            dateFormatter.locale = locale

            return dateFormatter.string(from: self)
        }
    }

    func timeDifference() -> String {
        guard let secondsPassed = Calendar.current.dateComponents([.second],
                                                                  from: self, to: Date()).second else { return "" }

        switch secondsPassed {
        case let seconds where seconds < 60:
            return "< 1 min"
        case let seconds where seconds < 3600:
            return "\(Int(seconds / 60)) min"
        case let seconds where seconds < 172800:
            return "\(Int(seconds / 3600)) h"
        case let seconds where seconds >= 172800:
            return "\(Int(seconds / 86400)) \("time_days_abrv".localized)"
        default:
            return ""
        }
    }

    func dayDifference() -> String {
        guard let daysPassed = Calendar.current.dateComponents([.day], from: self, to: Date()).day else { return "" }
        switch daysPassed {
        case let days where days == 0:
            return "Today"
        case let days where days == 1:
            return "Yesterday"
        case let days where days > 1:
            return "\(days) \("time_days_abrv".localized) \("checklists_ago".localized(group: .checklists))"
        default:
            return "-"
        }
    }

    func dayDifferenceWithOnlyDate() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "today".localized
        } else if calendar.isDateInYesterday(self) {
            return "yesterday".localized
        } else {
            return asStringWith(format: .userFacingOnlyDate, timeZone: .current)
        }
    }

    var calendarDay: DateComponents {
        return Calendar.init(identifier: .iso8601).dateComponents([.day, .month, .year], from: self)
    }

    var relativeDay: String? {
        relativeDay(fallbackToDate: false)
    }

    var relativeDayDate: String? {
        relativeDay()
    }

    private func relativeDay(fallbackToDate: Bool = true) -> String? {
        let calendar = Calendar.init(identifier: .iso8601)

        let date = calendar.startOfDay(for: self)
        let today = calendar.startOfDay(for: Date())

        guard let daysDiff = calendar.dateComponents([.day], from: date, to: today).day else { return nil }

        switch daysDiff {
        case 0:
            return "today".localized
        case 1:
            return "yesterday".localized
        case 2..<7 where !fallbackToDate:
            return asStringWith(format: .custom(format: "EEEE"), timeZone: .current)
        case 7..<180  where !fallbackToDate:
            return asStringWith(format: .custom(format: "E d, MMM"), timeZone: .current)
        default:
            guard fallbackToDate else {
                return asStringWith(format: .custom(format: "d MMM, yyyy"), timeZone: .current)
            }

            return asStringWith(format: .userFacingOnlyDate, timeZone: .current)
        }
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }

    var year: Int { Calendar.current.component(.year, from: self) }
    var month: Int { Calendar.current.component(.month, from: self) }
    var day: Int { Calendar.current.component(.day, from: self) }
    var hour: Int { Calendar.current.component(.hour, from: self) }
    var minute: Int { Calendar.current.component(.minute, from: self) }
    var second: Int { Calendar.current.component(.second, from: self) }
}

public extension DateComponents {
    var dateFromCalendarDate: Date? {
        return Calendar.init(identifier: .iso8601).date(from: self)
    }

    var dayDescription: String? {
        guard let day = day, let month = month, let year = year else { return nil }
        return String(format: "%.2ld/%.2ld/%ld", day, month, year)
    }

    var isoDayDescription: String? {
        guard let day = day, let month = month, let year = year else { return nil }
        return String(format: "%ld-%.2ld-%.2ld", year, month, day)
    }
}

public extension Date {
    func startOfWeek(usingFirstWeekday firstWeekday: Int? = nil) -> Date {
        var calendar = Calendar.current
        if let firstWeekday {
            calendar.firstWeekday = firstWeekday
        }

        var startOfTheWeek = self
        var interval = TimeInterval(0)
        _ = calendar.dateInterval(of: .weekOfYear, start: &startOfTheWeek, interval: &interval, for: startOfTheWeek)
        return startOfTheWeek
    }
    var startOfWeek: Date { startOfWeek() }

    func endOfWeek(usingFirstWeekday firstWeekday: Int? = nil) -> Date {
        let startOfTheWeek = startOfWeek(usingFirstWeekday: firstWeekday)
        var calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 7, to: startOfTheWeek)! // Next week start day at 00:00:00
        return calendar.date(byAdding: .second, value: -1, to: nextDay)! // End of week day at 23:59:59
    }
    var endOfWeek: Date { endOfWeek() }

    func weekNumber(using calendar: Calendar = .current) -> Int {
        return calendar.component(.weekOfYear, from: self)
    }
    var weekNumber: Int { weekNumber() }

    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }

    func endOfMonth() -> Date {
        guard let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.startOfMonth()) else {
            fatalError("Could not calculate the start of the next month.")
        }
        return Calendar.current.date(byAdding: .second, value: -1, to: startOfNextMonth)!
    }
}

public extension Date {
    func dateFormatWithSuffix() -> String {
        return "\(dateDayFormatWithSuffix())' MMMM yyyy"
    }

    func dateDayFormatWithSuffix() -> String {
        return "dd'\(self.daySuffix())'"
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameDay(as date: Date?) -> Bool? {
        guard let date else { return nil }
        return isEqual(to: date, toGranularity: .day)
    }

    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }

    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}

public extension Date {
    // Returns a Date adjusted to the current timeZone from the provided timeZone (or UTC by default)
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String = "UTC") -> Date? {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))

            return self.addingTimeInterval(localOffset - targetOffset)
        }

        return nil
    }
}

public extension Array where Element == Date {
    func containsDate(_ date: Date) -> Bool {
        let componentsToCompare: Set<Calendar.Component> = [.year, .month, .day]

        for existingDate in self {
            let existingComponents = Calendar.current.dateComponents(componentsToCompare, from: existingDate)
            let dateToCompareComponents = Calendar.current.dateComponents(componentsToCompare, from: date)

            if existingComponents == dateToCompareComponents {
                return true
            }
        }
        return false
    }
}

public extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
}
