//
//  post.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/21.
//

struct Items {
    var item: [Item]
}

struct Item {
    var title : String?
    var link : String?
    var description : String?
    var categories : [Category]?
    var date : String?
    
}

struct Category {
    var category : String?
}


enum XMLKey : String {
    
    case title = "title"
    case link = "link"
    case description = "description"
    case category = "category"
    case date = "pubdate"
}
