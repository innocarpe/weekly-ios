//
//  TodoPoint+CoreDataProperties.swift
//  
//
//  Created by YunSeungyong on 2015. 8. 1..
//
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension TodoPoint {

    @NSManaged var title: String?
    @NSManaged var note: String?
    @NSManaged var priority: NSNumber?
    @NSManaged var state: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var modifiedAt: NSDate?
    @NSManaged var type: NSNumber?
    @NSManaged var weekOfYear: NSNumber?
    @NSManaged var weekDay: NSNumber?
    @NSManaged var year: NSNumber?
}
