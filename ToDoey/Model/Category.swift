//
//  Category.swift
//  ToDoey
//
//  Created by David A Cantú Delgado on 11/25/18.
//  Copyright © 2018 Bugsracer. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name :  String = ""
    @objc dynamic var color : String = "#FFFFFF"
    let items = List<Item>()
}
