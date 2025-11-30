//
//  Date+Extensions.swift
//  LifePlanner
//

import Foundation

extension Date {
    func daysBetween(_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: endDate)
        return components.day ?? 0
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isWithinRange(start: Date, end: Date) -> Bool {
        self >= start && self <= end
    }
}

extension Event {
    var spansDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    func spansDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        return (startDate < dayEnd && endDate >= dayStart)
    }
    
    func isFirstDayOf(_ date: Date) -> Bool {
        Calendar.current.isDate(startDate, inSameDayAs: date)
    }
    
    func isLastDayOf(_ date: Date) -> Bool {
        Calendar.current.isDate(endDate, inSameDayAs: date)
    }
}

