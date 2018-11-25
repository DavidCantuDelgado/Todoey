//
//  Item.swift
//  ToDoey
//
//  Created by David A Cantú Delgado on 11/25/18.
//  Copyright © 2018 Bugsracer. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var item : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}


