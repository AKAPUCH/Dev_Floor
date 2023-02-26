//
//  BlogPostViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit



final class BlogPostViewController: UIViewController {
    
    private let tableView = UITableView()
    private var webView : WebviewPost? = nil
    var blogs : [Blog] = []
    var blogPosts: [BlogPost] = []
    var parser = XMLParser()
    var includetext : String = ""
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        searchBar.delegate = self
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getNetwork(blogs)
        
    }
    
    func getJsonData() {
        let jsonDecoder : JSONDecoder = JSONDecoder()
        
        guard let dataAsset1 : NSDataAsset = NSDataAsset.init(name: "devBlog" ) else {return}
        
        do{
            self.blogs = try jsonDecoder.decode([Blog].self, from: dataAsset1.data)
        }catch {
            print(error.localizedDescription)
        }
        blogs = blogs.filter{$0.rss != nil && $0.blog!.contains("tistory") && $0.rss != "http://hongji3354.tistory.com/rss"}
        //       print(blogs)
    }
    
    func getNetwork(_ content : [Blog]) {
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
            }
            
            task.resume()
        }
    }
    
    func setTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "BlogCell")
    }
    
    func setConstraints() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
        }
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.tableView.snp.top)
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

extension BlogPostViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter your array based on the search text
        blogPosts.removeAll()
        includetext = searchText
        getNetwork(blogs)
    }
    
    //    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    //        // Clear the search bar text and dismiss the keyboard
    //        searchBar.text = ""
    //        searchBar.resignFirstResponder()
    //    }
    
    
}


extension BlogPostViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        if blogPosts.isEmpty {return cell}
        let currentBlogPost : BlogPost = blogPosts[indexPath.row]
        cell.postTitle.text = currentBlogPost.title
        cell.postIntroduction.text = currentBlogPost.date + "\n" + currentBlogPost.category
        return cell
    }
    
    
    
    
}


extension BlogPostViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else { return }
        
        let tapLocation = tableView.panGestureRecognizer.location(in: cell)
        if let accessoryView = cell.accessoryView,
           accessoryView.frame.contains(tapLocation) {
            // Accessory view was selected
            // Do something...
            switch cell.bookmarkStar.image {
            case UIImage(systemName: "star") : cell.bookmarkStar.image = UIImage(systemName: "star.fill")
            case UIImage(systemName: "star.fill") : cell.bookmarkStar.image = UIImage(systemName: "star")
            default : break
            }
        } else {
            // Stack view was selected
            print("Stack view was selected")
            // Do something...
            webView = WebviewPost()
            webView?.blogPostURL = URL(string: blogPosts[indexPath.row].link)
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
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async { [weak self] in
            self!.tableView.reloadData()
        }
    }
    
    
}


