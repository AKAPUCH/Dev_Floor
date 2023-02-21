//
//  BlogPostViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit



final class BlogPostViewController: UIViewController {
    
    private let tableView = UITableView()
    var tf : Bool = false
    var blogs : [Blog] = []
    var items : [Item] = []
    var categoryBasket : [Category] = []
    var xmlDictionary : [String : String]?
    var crtElementType : XMLKey?
    var parser = XMLParser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getNetwork()
        print(3)
    }
    
    func getJsonData() {
        let jsonDecoder : JSONDecoder = JSONDecoder()
        
        guard let dataAsset1 : NSDataAsset = NSDataAsset.init(name: "devBlog" ) else {return}
        
        do{
            self.blogs = try jsonDecoder.decode([Blog].self, from: dataAsset1.data)
        }catch {
            print(error.localizedDescription)
        }
//        print(blogs)
    }
    
    func getNetwork() {
        blogs = blogs.filter{$0.rss == "https://all-dev-kang.tistory.com/rss"}
        let url = URL(string: blogs[0].rss!)

            self.parser = XMLParser(contentsOf: url!)!
            self.parser.delegate = self
            self.parser.parse()
        
    }
    
    func setTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "BlogCell")
    }
    
    func setConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func setNavi() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithOpaqueBackground()
                navigationController?.navigationBar.standardAppearance = navigationBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.tintColor = .systemBlue

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance

                navigationController?.setNeedsStatusBarAppearanceUpdate()
                
                navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
                title = "목록"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BlogPostViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        cell.bookmarkStar.image = UIImage(systemName: "star")
        cell.postTitle.text = "테스트 제목"
        cell.postIntroduction.text = "테스트 내용은 다음과 같습니다"
        return cell
    }
    
    
}

extension BlogPostViewController : UITableViewDelegate {
    
}

extension BlogPostViewController : XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print(elementName)
        switch elementName {
        case "item" :   xmlDictionary = [:]
        case "title" :  crtElementType = .title
        case "link" :   crtElementType = .link
        case "description" :    crtElementType = .description
        case "category" :       crtElementType = .category
        case "date" : crtElementType = .date
        default : break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {

        guard var xmlDictionary, var crtElementType else {return}
        xmlDictionary.updateValue(string, forKey: crtElementType.rawValue)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        guard var xmlDictionary else {return}
        if elementName == "item" {
            var item = Item()
            item.title = xmlDictionary[XMLKey.title.rawValue]
            item.link = xmlDictionary[XMLKey.link.rawValue]
            item.description = xmlDictionary[XMLKey.description.rawValue]
            item.categories = categoryBasket
            item.date = xmlDictionary[XMLKey.date.rawValue]
            items.append(item)
            xmlDictionary.removeAll()
        }
        else if elementName == "category" {
            var categoryObject = Category()
            guard let categoryName = xmlDictionary[XMLKey.category.rawValue] else {return}
            categoryObject.category = categoryName
            categoryBasket.append(categoryObject)
        }
        crtElementType = nil
        
    }
    
    
}


