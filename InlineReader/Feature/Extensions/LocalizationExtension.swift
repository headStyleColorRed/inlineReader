//
//  LocalizationExtension.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 9/5/22.
//  Copyright © 2022 airun. All rights reserved.
//

import Foundation

public enum LocalizedGroups: String {
    case news = "strings_news"
    case clock = "strings_clockin"
    case profile = "strings_profile"
    case roster = "strings_roster"
    case forms = "strings_dynamicforms"
    case hrpacks = "strings_hrpacks"
    case chat = "strings_chat"
    case profileV1 = "strings_profile_old"
    case checklists = "strings_checklists"
    case proMaintenance = "strings_maintenance"
    case reMaintenance = "strings_maintenance_issues"
    case tasks = "strings_tasks"
    case notification = "strings_notification"
    case idcard = "strings_idcard"
    case terms = "strings_terms"
    case login = "strings_login"
    case tabBar = "strings_main"
    case comments = "strings_comments"
    case shiftnotes = "strings_shift_notes"
    case moments = "strings_moments"
    case checkin = "strings_checkin"
    case v2Roster = "strings_v2_roster"
    case leaveRequest = "strings_leave_request"
    case appointments = "strings_appointments"
    case home = "strings_home"
    case mySchedule = "strings_my_shedule"
    case holidays = "strings_holiday_approval"
    case orgChart = "strings_org_chart"
    case packsAndCheckins = "strings_checkpackveys"
    case evacList = "strings_evac_list"
    case nfc = "strings_nfc"
    case emptyState = "strings_empty_state"
    case housekeeping = "strings_housekeeping"
    case docStore = "strings_doc_store"
    case visitors = "strings_visitors"
    case suppliers = "strings_suppliers"
    case lostAndFound = "strings_lost_and_found"
    case concierge = "strings_concierge"
    case awards = "strings_awards"
    case upsertBanners = "strings_upsertBanners"
    case library = "strings_library"
}

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }

    func localized(group: LocalizedGroups) -> String {
        return NSLocalizedString(self, tableName: group.rawValue, comment: self)
    }
}
