//
//  CalendarUtils.swift
//  Weekly
//
//  Created by Wooseong Kim on 2015. 8. 2..
//  Copyright © 2015년 Wooseong Kim. All rights reserved.
//

import UIKit

class CalendarUtils: NSObject {
    static let calendar = NSCalendar.autoupdatingCurrentCalendar()
    
    class func getNumberOfWeeksOfYear(year: Int) -> Int {
        let components = calendar.components([.YearForWeekOfYear, .WeekOfYear, .Weekday], fromDate: NSDate())
        components.yearForWeekOfYear = year
        
        let targetDate = calendar.dateFromComponents(components)
        
        return calendar.rangeOfUnit(.WeekOfYear, inUnit:.YearForWeekOfYear, forDate: targetDate!).length
    }
    
    class func getDateFromComponents(year: Int, weekOfYear: Int, weekday: Int) -> NSDate! {
        let calendarUnit: NSCalendarUnit = [.YearForWeekOfYear, .WeekOfYear, .Weekday]
        let components = calendar.components(calendarUnit, fromDate: NSDate())
        components.yearForWeekOfYear = year
        components.weekOfYear = weekOfYear
        components.weekday = weekday
        
        return calendar.dateFromComponents(components)
    }
    
    class func getDayFromComponents(year: Int, weekOfYear: Int, weekday: Int) -> Int {
        let targetDate = getDateFromComponents(year, weekOfYear: weekOfYear, weekday: weekday)
        let targetCalendarUnit: NSCalendarUnit = [.Day]
        let targetComponents = calendar.components(targetCalendarUnit, fromDate: targetDate)
        
        return targetComponents.day
    }
    
    class func isDateComponentEqualToday(year: Int, weekOfYear: Int, weekday: Int) -> Bool {
        let calendarUnit: NSCalendarUnit = [.Year, .WeekOfYear, .Weekday]
        let components = calendar.components(calendarUnit, fromDate: NSDate())
    
        return components.year == year && components.weekOfYear == weekOfYear  && components.weekday == weekday
    }
}
