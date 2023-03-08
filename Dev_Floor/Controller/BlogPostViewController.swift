//
//  BlogPostViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit
import CoreData



final class BlogPostViewController: UIViewController {
    
    private let tableView = UITableView()
    private var webView : WebviewPost? = nil
    var blogs : [Blog] = []
    var startIndex = 0
    var endIndex = 30
    var currentPosts : [BlogPost] = [] // 현재 참조 데이터
    var tableShowedPosts : [BlogPost] = [] // 현재 테이블 뷰 데이터
    var blogPosts: [BlogPost] = [] // 네트워킹 후 전체 데이터 저장
    var parser = XMLParser()
    var includetext : String = ""
    var container : NSPersistentContainer!
    var eName = String()
    var postTitle = String()
    var postLink = String()
    var categoryText = String()
    var contents = String()
    var postDate = String()
    
    var searchBar : UISearchBar = {
        let set = UISearchBar()
        set.spellCheckingType = .no
        set.autocorrectionType = .no
        set.autocapitalizationType = .none
        set.barStyle = .default
        return set
    }()
    
    lazy var searchResult : UILabel = {
        let set = UILabel()
        set.text = "\(self.blogPosts.count)건이 검색되었습니다."
        set.textColor = .clear
        
        return set
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        searchBar.delegate = self
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getNetwork(blogs) {
            self.currentPosts = self.blogPosts
        }
        getContainer()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("소멸1")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("곧사라진다")
    }
    
    // MARK: - 코어 데이터 관련
    func getContainer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        selectData()
    }
    
    func createBookmark(_ currentPost : BlogPost) {
        guard let entity = NSEntityDescription.entity(forEntityName: "BookmarkedPost", in: self.container.viewContext) else {return}
        let savedObject = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        savedObject.setValue(currentPost.title, forKey: "title")
        savedObject.setValue(currentPost.link, forKey: "link")
        savedObject.setValue(currentPost.category, forKey: "category")
        savedObject.setValue(currentPost.contents, forKey: "contents")
        savedObject.setValue(currentPost.date, forKey: "date")
        do {
            try self.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func selectData() {
        do{
            let contact = try self.container.viewContext.fetch(BookmarkedPost.fetchRequest())
            //배열형태로 불러온 데이터
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteBookmark(_ currentPost : BlogPost) {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "BookmarkedPost")
        fetchRequest.predicate = NSPredicate(format: "link = %@", currentPost.link ?? "www.naver.com")
        
        do {
            let test = try self.container.viewContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            self.container.viewContext.delete(objectToDelete)
            do {
                try self.container.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - dataAsset JSON파일 파싱
    func getJsonData() {
        let jsonDecoder : JSONDecoder = JSONDecoder()
        
        guard let dataAsset1 : NSDataAsset = NSDataAsset.init(name: "devBlog" ) else {return}
        
        do{
            self.blogs = try jsonDecoder.decode([Blog].self, from: dataAsset1.data)
        }catch {
            print(error.localizedDescription)
        }
        blogs = blogs.filter{$0.rss != nil && $0.blog!.contains("tistory") && $0.rss != "http://hongji3354.tistory.com/rss"}
        
    }
    
    
    // MARK: - XML파싱
    func getNetwork(_ content : [Blog], completion : @escaping () -> Void) {
        for i in content{
            guard let url = URL(string: i.rss!) else { return }
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data returned from server")
                    return
                }
                
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                completion()
            }
            
            task.resume()
        }
    }
    
    
    // MARK: - UI관련
    func setTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "BlogCell")
    }
    
    func setConstraints() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(searchResult)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(80)
        }
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.tableView.snp.top).offset(-30)
        }
        searchResult.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.searchBar.snp.bottom)
            make.bottom.equalTo(self.tableView.snp.top).offset(-20)
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
    
    
    
}

extension BlogPostViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.tableView.contentSize.height
        let pagination_y = tableViewContentSize * 0.2
        
        if contentOffset_y > tableViewContentSize - pagination_y {
            
            endIndex = currentPosts.count - 1
            if startIndex > endIndex {return}
            tableShowedPosts += Array(currentPosts[startIndex...(endIndex - startIndex > 30 ? startIndex + 30 : endIndex)])
            startIndex += 30
            tableView.reloadData()
            
            
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)    {
//        let contentOffset_y = scrollView.contentOffset.y
//        let tableViewContentSize = self.tableView.contentSize.height
//        let pagination_y = tableViewContentSize * 0.2
//
//        if contentOffset_y > tableViewContentSize - pagination_y {
//
//            endIndex = currentPosts.count - 1
//            if startIndex > endIndex {return}
//            tableShowedPosts += Array(currentPosts[startIndex...(endIndex - startIndex > 30 ? startIndex + 30 : endIndex)])
//            startIndex += 30
//            tableView.reloadData()
//
//
//        }
//    }
}

extension BlogPostViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter your array based on the search text
        
        if searchText == "" {
            currentPosts = blogPosts
            searchResult.textColor = .clear
            startIndex = 0
            tableShowedPosts.removeAll()
            endIndex = currentPosts.count - 1
            if startIndex > endIndex {return}
            tableShowedPosts += Array(currentPosts[startIndex...(endIndex - startIndex > 30 ? startIndex + 30 : endIndex)])
            startIndex += 30
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            currentPosts = blogPosts.filter{$0.category?.contains(searchText) ?? false}
            
            searchResult.text = "\(currentPosts.count)건이 검색되었습니다."
            searchResult.textColor = .black
            startIndex = 0
            tableShowedPosts.removeAll()
            endIndex = currentPosts.count - 1
            if startIndex > endIndex {return}
            tableShowedPosts += Array(currentPosts[startIndex...(endIndex - startIndex > 30 ? startIndex + 30 : endIndex)])
            startIndex += 30
            tableView.reloadData()
        }
    }
    
    
}


extension BlogPostViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableShowedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        let currentBlogPost : BlogPost = tableShowedPosts[indexPath.row]
        cell.postTitle.text = currentBlogPost.title
        cell.postIntroduction.text = (currentBlogPost.date ?? "날짜없음") + "\n" + (currentBlogPost.category ?? "카테고리없음" )
        return cell
    }
    
    
    
    
}


extension BlogPostViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else { return }
        let currentBlogPost : BlogPost = blogPosts[indexPath.row]
        let tapLocation = tableView.panGestureRecognizer.location(in: cell)
        if let accessoryView = cell.accessoryView,
           accessoryView.frame.contains(tapLocation) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadTableViewData1"), object: nil)
            // Accessory view was selected
            // Do something...
            switch cell.bookmarkStar.image {
            case UIImage(systemName: "star") :
                cell.bookmarkStar.image = UIImage(systemName: "star.fill")
                createBookmark(currentBlogPost)
                selectData()
            case UIImage(systemName: "star.fill") :
                cell.bookmarkStar.image = UIImage(systemName: "star")
                deleteBookmark(currentBlogPost)
                
            default : break
            }
        } else {
            // Stack view was selected
            print("Stack view was selected")
            // Do something...
            webView = WebviewPost()
            webView?.blogPostURL = URL(string: blogPosts[indexPath.row].link ?? "www.naver.com")
            navigationController?.pushViewController(webView!, animated: true)
        }
    }
    
}



extension BlogPostViewController : XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        eName = elementName
        if elementName == "item" {
            postTitle = String()
            postLink = String()
            categoryText = String()
            postDate = String()
            contents = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if includetext != ""{
                guard categoryText.contains(includetext) else {return}
            }
            let blogPost: BlogPost = BlogPost()
            blogPost.title = postTitle
            blogPost.link = postLink
            blogPost.category = categoryText
            blogPost.contents = contents
            blogPost.date = postDate
            blogPosts.append(blogPost)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (!data.isEmpty) {
            if eName == "title" {
                postTitle += data
            } else if eName == "link" {
                postLink += data
            } else if eName == "category" {
                categoryText += data + " "
            } else if eName == "pubDate" {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                if let date = dateFormatter.date(from: data) {
                    dateFormatter.dateFormat = "yyyy년 M월 d일"
                    let formattedDate = dateFormatter.string(from: date)
                    postDate = formattedDate
                } else {
                    print("Unable to parse date")
                }
            } else if eName == "description" {
                contents += data
            }
        }
        
    }
    //
    //    func parserDidEndDocument(_ parser: XMLParser) {
    //        blogPosts.append(<#T##newElement: BlogPost##BlogPost#>)
    //    }
    
    
}


