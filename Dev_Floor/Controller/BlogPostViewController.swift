//
//  BlogPostViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit

class BlogPost {
    var title = String()
    var link = String()
    var contents = String()
    var category = String()
    var date = String()
}

final class BlogPostViewController: UIViewController {
    
    private let tableView = UITableView()
    private var webView : WebviewPost? = nil
    var blogs : [Blog] = []
    var blogPosts: [BlogPost] = []
    var parser = XMLParser()
    
    var eName = String()
    var postTitle = String()
    var postLink = String()
    var categoryText = String()
    var contents = String()
    var postDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setNavi()
        setTable()
        setConstraints()
        getJsonData()
        getNetwork()
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
        blogs = blogs.filter{$0.rss == "https://bob-full.tistory.com/rss"}
        let url = URL(string: blogs[0].rss!)
        self.parser.delegate = self
        
        DispatchQueue.global(qos: .background).async {
            if let parser = XMLParser(contentsOf: url!) {
                parser.parse()
            } else {
                print("Failed to initialize XMLParser with contents of URL: \(url!)")
            }
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
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        let currentBlogPost : BlogPost = blogPosts[indexPath.row]
        cell.bookmarkStar.image = UIImage(systemName: "star")
        cell.postTitle.text = currentBlogPost.title
        cell.postIntroduction.text = currentBlogPost.date + "\n" + currentBlogPost.category
        print(currentBlogPost.date)
        return cell
    }
    
    
}

extension BlogPostViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        webView = WebviewPost()
        print(blogPosts[indexPath.row].link)
        webView?.blogPostURL = URL(string: blogPosts[indexPath.row].link)
        navigationController?.pushViewController(webView!, animated: true)
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
        self.tableView.reloadData()
    }
    
    
}


