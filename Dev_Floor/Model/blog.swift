//
//  blog.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/19.
//

import Foundation

struct Blog : Codable {
    var name : String?
    var blog : String?
    var github : String?
    var description : String?
    var rss : String?
//    "name": "강경석",
//    "blog": "https://all-dev-kang.tistory.com/",
//    "github": "https://github.com/gyeongseokKang",
//    "description": "편리함을 추구하는 개발자의 지식 블로그",
//    "rss": "https://all-dev-kang.tistory.com/rss"
}

class BlogPost {
    var title : String?
    var link : String?
    var contents : String?
    var category : String?
    var date : Date?
    
    init(title: String? = nil, link: String? = nil, contents: String? = nil, category: String? = nil, date: Date? = nil) {
        self.title = title
        self.link = link
        self.contents = contents
        self.category = category
        self.date = date
    }
}
