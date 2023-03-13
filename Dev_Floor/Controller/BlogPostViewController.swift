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
    var blogs : [Blog] = []
    var currentDate : Date? // 코어 데이터의 엔티티 중 가장 최근 날짜를 담습니다.
    var pageNumber = 0
    var latestPosts: [BlogPost] = [] // 네트워킹 후 최신 데이터 저장
    var totalPosts : [BlogPost] = [] // 전체 데이터 저장
    var currentPosts : [BlogPost] = [] //검색했을 때를 고려, 현재 참조중인 배열
    var searchedPosts : [BlogPost] = [] // 실제 테이블의 데이터 배열
    var updatedTime : Int = 0 // 최신 데이터 갱신 여부
    var includeText : String = ""
    var container : NSPersistentContainer!
    
    // MARK: - 파싱한 데이터 담는 변수들
    var eName : String?
    var postTitle : String?
    var postLink : String?
    var categoryText = ""
    var contents : String?
    var postDate : String?
    
    
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
        
        view.backgroundColor = UIColor.systemBackground
        searchBar.delegate = self
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getContainer()
        
        
        
    }
    
    // MARK: - 코어 데이터 관련
    func getContainer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        //최초 로드시 테이블 뷰 데이터를 갱신합니다.
        getOldPosts(pageNumber) {[self] in
            tableView.reloadData()
            getNetwork(blogs)
        }
    }
    
    
    // MARK: - latestPosts 배열의 데이터를 core data에 저장
    func savePosts(_ latestPost : [BlogPost]) {
        let dispatchGroup = DispatchGroup()
        guard let entity = NSEntityDescription.entity(forEntityName: "OldPost", in: self.container.viewContext) else {return}
        let savedObject = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        for currentPost in latestPost {
            dispatchGroup.enter()
            DispatchQueue.global(qos: .background).async { [self] in
                savedObject.setValue(currentPost.title, forKey: "title")
                savedObject.setValue(currentPost.link, forKey: "link")
                savedObject.setValue(currentPost.category, forKey: "category")
                savedObject.setValue(currentPost.contents, forKey: "contents")
                savedObject.setValue(currentPost.date, forKey: "date")
                savedObject.setValue(currentPost.isBookmarked, forKey: "isBookmarked")
                
                do {
                    try container.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [self] in
            tableView.reloadData()
        }
        
    }
    
    // MARK: - 날짜 오름차순으로 core data에서 데이터를 불러오고, 완료되면 totalPosts 배열에 저장
    func getOldPosts(_ pageNum : Int, _ completion : @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async { [self] in
            let fetchRequest: NSFetchRequest<OldPost> = OldPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            fetchRequest.fetchOffset = pageNumber * 30
            fetchRequest.fetchLimit = 30
            do {
                let fetchedResults = try container.viewContext.fetch(fetchRequest)
                if currentDate == nil, fetchedResults.count != 0 {currentDate = fetchedResults[0].date}
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
    func getSearchedPosts(_ pageNum : Int, _ searchText : String, _ completion : @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async { [self] in
            let fetchRequest: NSFetchRequest<OldPost> = OldPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            let predicate = NSPredicate(format: "(title CONTAINS[c] %@ OR content CONTAINS[c] %@) AND searchtext == %@", searchText, searchText, searchText)
            fetchRequest.predicate = predicate
            fetchRequest.fetchOffset = pageNumber * 30
            fetchRequest.fetchLimit = 30
            do {
                let fetchedResults = try container.viewContext.fetch(fetchRequest)
                if currentDate == nil, fetchedResults.count != 0 {currentDate = fetchedResults[0].date}
                // 가장 최근 날짜 가져오기
                searchedPosts += reassembleEntity(fetchedResults)
                //페이지네이션마다 30개씩 가져오기
                completion()
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }

    
    // MARK: - 로컬 db 전체데이터 삭제용.
    //    func deleteAllPosts(_ currentPost : BlogPost) {
    //
    //        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "BookmarkedPost")
    //        fetchRequest.predicate = NSPredicate(format: "link = %@", currentPost.link ?? "www.naver.com")
    //
    //        do {
    //            let test = try self.container.viewContext.fetch(fetchRequest)
    //            let objectToDelete = test[0] as! NSManagedObject
    //            self.container.viewContext.delete(objectToDelete)
    //            do {
    //                try self.container.viewContext.save()
    //            } catch {
    //                print(error.localizedDescription)
    //            }
    //        } catch {
    //            print(error.localizedDescription)
    //        }
    //    }
    

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
                         date : $0.date,
                         isBookmarked : $0.isBookmarked
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
        func getNetwork(_ content: [Blog]) {
            if currentDate != nil {return} // 이미 최신 정보를 갱신한 이력이 있다면, 작업을 취소
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
                }
                
                dispatchGroup.enter()
                task.resume()
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {[self] in
                // 날짜순 정렬 후, 최종배열에 더해주기
                latestPosts.sort{$0.date! < $1.date!}
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
                        getOldPosts(pageNumber) { [self] in
                            currentPosts = totalPosts
                            UIView.animate(withDuration: 1) {[self] in
                                tableView.reloadData()
                            }
                            pageNumber += 1
                        }
                    }
                    else {
                        pageNumber = 0
                        getSearchedPosts(pageNumber,includeText) { [self] in
                            currentPosts = totalPosts
                            UIView.animate(withDuration: 1) {[self] in
                                tableView.reloadData()
                            }
                            pageNumber += 1
                        }
                    }
                }
            }
    }
    
    
    // MARK: - 검색 바 구현
    extension BlogPostViewController : UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Filter your array based on the search text
            
            if searchText == "" {
                currentPosts = latestPosts
                searchResult.textColor = .clear
                tableView.reloadData()
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            if let searchText = searchBar.text {
                currentPosts = latestPosts.filter{$0.category?.contains(searchText) ?? false}
                
                searchResult.text = "\(currentPosts.count)건이 검색되었습니다."
                searchResult.textColor = .black
                tableView.reloadData()
            }
        }
        
        
    }
    
    
    // MARK: - 테이블 뷰 설정, reloadData시 호출
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
    
    
    // MARK: - 즐겨찾기 등록/해제 시 화면 로직
    extension BlogPostViewController : UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else { return }
            let currentBlogPost : BlogPost = latestPosts[indexPath.row]
            let tapLocation = tableView.panGestureRecognizer.location(in: cell)
            if let accessoryView = cell.accessoryView,
               accessoryView.frame.contains(tapLocation) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadTableViewData1"), object: nil)
                // Accessory view was selected
                // Do something...
                switch cell.bookmarkStar.image {
                case UIImage(systemName: "star") :
                    cell.bookmarkStar.image = UIImage(systemName: "star.fill")
                    
                case UIImage(systemName: "star.fill") :
                    cell.bookmarkStar.image = UIImage(systemName: "star")
                    //                deleteBookmark(currentBlogPost)
                    
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
                postDate = ""
                contents = ""
            }
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if elementName == "item" {
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
            //let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
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
                        dateFormatter.dateFormat = "yyyy년 M월 d일"
                        let formattedDate = dateFormatter.string(from: date)
                        postDate = formattedDate
                    } else {
                        print("Unable to parse date")
                    }
                } else if eName == "description" {
                    contents = data
                }
            }
            
        }
        
        
    }
    
    
