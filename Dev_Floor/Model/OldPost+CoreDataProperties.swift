//
//  BookmarkedPost+CoreDataProperties.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/26.
//
//

import Foundation
import CoreData


extension OldPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OldPost> {
        return NSFetchRequest<OldPost>(entityName: "BookmarkedPost")
    }

    @NSManaged public var title: String?
    @NSManaged public var link: String?
    @NSManaged public var category: String?
    @NSManaged public var contents: String?
    @NSManaged public var date: Date?
    @NSManaged public var isBookmarked: Bool

}

extension OldPost : Identifiable {

}
