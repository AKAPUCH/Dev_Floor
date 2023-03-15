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
    private var webView : WebviewPost?
    var parsingCount : Int = 0
    var blogs : [Blog] = []
    var currentDate : Date? // 코어 데이터의 엔티티 중 가장 최근 날짜를 담습니다.
    var pastDate : Date = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
    var pageNumber = 0
    var latestPosts: [BlogPost] = [] // 네트워킹 후 최신 데이터 저장
    var totalPosts : [BlogPost] = [] // 전체 데이터 저장
    var searchedPosts : [BlogPost] = [] // 실제 테이블의 데이터 배열
    var updatedTime : Int = 0 // 최신 데이터 갱신 여부
    var includeText : String = ""
    //    var somethingLoading : Bool = false
    var container : NSPersistentContainer!
    // MARK: - 파싱한 데이터 담는 변수들
    var eName : String?
    var postTitle : String?
    var postLink : String?
    var categoryText = ""
    var contents : String?
    var postDate : Date?
    
    
    // MARK: - 서치바, 검색 결과 라벨
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
        set.textColor = .black
        set.font = .systemFont(ofSize: 14)
        return set
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = pastDate
        view.backgroundColor = UIColor.systemBackground
        searchBar.delegate = self
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getContainer()
        deleteAllPosts()
        getTableData()
    }
    
    // MARK: - 코어 데이터 관련
    func getContainer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    // MARK: - 테이블 데이터 관련
    func getTableData() {
        //최초 로드시 테이블 뷰 데이터를 갱신합니다.
        getOldPosts() {[self] in
            if currentDate != pastDate {
                tableView.reloadData()
                pageNumber += 1
            }
            getNewPost(blogs)
        }
    }
    
    
    // MARK: - latestPosts 배열의 데이터를 core data에 저장
    func savePosts(_ latestPosts: [BlogPost]) {
        let dispatchGroup = DispatchGroup()
        let backgroundContext = container.newBackgroundContext()
        
        for currentPost in latestPosts {
            dispatchGroup.enter()
            
            let savedObject = OldPost(context: backgroundContext)
            savedObject.title = currentPost.title
            savedObject.link = currentPost.link
            savedObject.category = currentPost.category
            savedObject.contents = currentPost.contents
            savedObject.date = currentPost.date
            savedObject.isBookmarked = false
            
            do {
                try backgroundContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("register latest posts")
        }
    }
    
    
    
    // MARK: - 날짜 오름차순으로 core data에서 데이터를 불러오고, 완료되면 totalPosts 배열에 저장
    func getOldPosts(_ completion : @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            let fetchRequest: NSFetchRequest<OldPost> = OldPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.fetchOffset = pageNumber * 30
            fetchRequest.fetchLimit = 30
            do {
                let fetchedResults = try container.viewContext.fetch(fetchRequest)
                if currentDate == pastDate, fetchedResults.count != 0 {currentDate = fetchedResults[0].date}
                // 가장 최근 날짜 가져오기
                totalPosts += reassembleEntity(fetchedResults)
                //페이지네이션마다 30개씩 가져오기
                completion()
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - 검색 시
    func getSearchedPosts(_ searchText : String, _ completion : @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let fetchRequest: NSFetchRequest<OldPost> = OldPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let predicate = NSPredicate(format: "(title CONTAINS[c] %@ OR content CONTAINS[c] %@) AND searchtext == %@", searchText, searchText, searchText)
            fetchRequest.predicate = predicate
            fetchRequest.fetchOffset = pageNumber * 30
            fetchRequest.fetchLimit = 30
            do {
                let fetchedResults = try container.viewContext.fetch(fetchRequest)
                searchedPosts += reassembleEntity(fetchedResults)
                //페이지네이션마다 30개씩 가져오기
                completion()
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - 로컬 db 전체데이터 삭제용.
    func deleteAllPosts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OldPost")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - 즐겨찾기 등록/해제 시 북마크 속성 업데이트
    func manageBookmarks(_ currentPost : BlogPost) {
        let fetchRequest: NSFetchRequest<OldPost> = NSFetchRequest.init(entityName: "OldPost")
        fetchRequest.predicate = NSPredicate(format: "link = %@", currentPost.link!)
        
        do {
            let result = try self.container.viewContext.fetch(fetchRequest)
            if let post = result.first {
                post.isBookmarked.toggle()
            }
            do {
                try self.container.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - core Data 엔티티 -> 구조체 변환
    func reassembleEntity(_ Entity : [OldPost]) -> [BlogPost] {
        return Entity.map{
            BlogPost(title: $0.title,
                     link : $0.link,
                     contents : $0.contents,
                     category : $0.category,
                     date : $0.date
            )
        }
    }
    
    // MARK: - 블로그 정보 json파일을 blogs 배열에 저장
    func getJsonData() {
        let jsonDecoder : JSONDecoder = JSONDecoder()
        
        guard let dataAsset1 : NSDataAsset = NSDataAsset.init(name: "devBlog" ) else {return}
        
        do{
            self.blogs = try jsonDecoder.decode([Blog].self, from: dataAsset1.data)
        }catch {
            print(error.localizedDescription)
        }
        blogs = blogs.filter{$0.rss != nil && $0.blog!.contains("tistory")}
    }
    
    
    // MARK: - blogs을 순회하며 rss로 비동기 통신 및 결과 xml파싱 시작
    func getNewPost(_ content: [Blog]) {
        let dispatchGroup = DispatchGroup()
        
        for i in content {
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
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main) {[self] in
            // 날짜순 정렬 후, 최종배열에 더해주기
            print(parsingCount)
            latestPosts.sort{$0.date! > $1.date!}
            totalPosts.insert(contentsOf: latestPosts, at: 0)
            savePosts(latestPosts)
            searchResult.text = "새로 추가된 포스트 \(latestPosts.count) 발견, 위로 스크롤시 갱신됩니다"
            updatedTime += 1
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
            make.bottom.equalTo(self.tableView.snp.top).offset(-10)
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
    
    func changeDateToString(_ date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
    
    
    
    
}


// MARK: - 페이지네이션 구현

extension BlogPostViewController : UIScrollViewDelegate {
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        // MARK: - 스크롤 위로(최신 데이터 가져오기)
        if contentOffsetY <= 0 {
            if updatedTime == 1{
                UIView.animate(withDuration: 1) {[self] in
                    tableView.reloadData()
                    //데이터 갱신 후 최상단으로 이동.
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                searchResult.textColor = .clear
                updatedTime += 1
            } else {
                searchResult.text = "최신정보를 가져오고 있습니다..."
            }
        }
        
        // MARK: - 스크롤 아래로(구 데이터 가져오기)
        if contentOffsetY >= contentHeight - frameHeight {
            if includeText == "" {
                getOldPosts() {
                    DispatchQueue.main.async { [self] in
                        tableView.reloadData()
                        pageNumber += 1
                    }
                    
                }
            }
            else {
                getSearchedPosts(includeText) {
                    DispatchQueue.main.async { [self] in
                        tableView.reloadData()
                        pageNumber += 1
                    }
                }
            }
        }
    }
}


// MARK: - 검색 바 구현
extension BlogPostViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter your array based on the search text
        includeText = searchText
        if searchText == "" {
            pageNumber = 0
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if updatedTime <= 1 {
            searchResult.text = "최신 정보 갱신 후 다시 시도해주세요!"
            return
        }
        let searchText = searchBar.text!
        pageNumber = 0
        searchedPosts.removeAll()
        if searchText == "" {
            tableView.reloadData()
        }
        else {
            getSearchedPosts(searchText) {[self] in
                tableView.reloadData()
            }
        }
    }
}


// MARK: - 테이블 뷰 설정, reloadData시 호출
extension BlogPostViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentBlogPost = includeText == "" ? totalPosts : searchedPosts
        return min(30, currentBlogPost.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        let currentBlogPost : BlogPost
        if includeText == "" {currentBlogPost = totalPosts[indexPath.row + pageNumber * 30]}
        else {currentBlogPost = searchedPosts[indexPath.row + pageNumber * 30]}
        cell.postTitle.text = currentBlogPost.title
        cell.postIntroduction.text = changeDateToString(currentBlogPost.date!)
        return cell
    }
    
    
    
    
}


// MARK: - 즐겨찾기 등록/해제 시 화면 로직
extension BlogPostViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else { return }
        let currentBlogPost : BlogPost
        if includeText == "" {currentBlogPost = totalPosts[indexPath.row + pageNumber * 30]}
        else {currentBlogPost = searchedPosts[indexPath.row + pageNumber * 30]}
        let tapLocation = tableView.panGestureRecognizer.location(in: cell)
        if let accessoryView = cell.accessoryView,
           accessoryView.frame.contains(tapLocation) {
            
            // Accessory view was selected
            switch cell.bookmarkStar.image {
            case UIImage(systemName: "star") :
                cell.bookmarkStar.image = UIImage(systemName: "star.fill")
                
            case UIImage(systemName: "star.fill") :
                cell.bookmarkStar.image = UIImage(systemName: "star")
                
            default : break
            }
            manageBookmarks(currentBlogPost)
        } else {
            // Stack view was selected
            print("Stack view was selected")
            // Do something...
            webView = WebviewPost()
            webView?.blogPostURL = URL(string: latestPosts[indexPath.row].link ?? "www.naver.com")
            navigationController?.pushViewController(webView!, animated: true)
        }
    }
    
}



// MARK: -  xml파싱 로직
extension BlogPostViewController : XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        eName = elementName
        if elementName == "item" {
            postTitle = ""
            postLink = ""
            categoryText = ""
            contents = ""
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if currentDate! > postDate! {
                return
            }
            parsingCount += 1
            let blogPost: BlogPost = BlogPost()
            blogPost.title = postTitle
            blogPost.link = postLink
            blogPost.category = categoryText
            blogPost.contents = contents
            blogPost.date = postDate
            latestPosts.append(blogPost)
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if eName == "title" {
                postTitle = data
            } else if eName == "link" {
                postLink = data
            } else if eName == "category" {
                categoryText += data + " "
            } else if eName == "pubDate" {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                if let date = dateFormatter.date(from: data) {
                    postDate = date
                } else {
                    print("Unable to parse date")
                }
            } else if eName == "description" {
                contents = data
            }
        }
        
    }
    
    
}


