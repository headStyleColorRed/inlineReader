//
//  DatePickerExtensions.swift
//  TestingSwiftUI
//
//  Created by Rodrigo Labrador Serrano on 9/11/24.
//

import SwiftUI

public extension DatePicker {
    public func withHourPlaceholder(for date: Binding<Date>) -> some View {
        var formattedHour: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date.wrappedValue)
        }

        return self.overlay(alignment: .trailing) {
            Text(formattedHour)
                .font(.system(size: 16, weight: .custom(400)))
                .padding(EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 15))
                .frame(minWidth: 80)
                .background(Color.white)
                .cornerRadius(8)
                .allowsHitTesting(false)
                .foregroundStyle(Color(hex: "#3B3B3B"))
        }
    }
}
