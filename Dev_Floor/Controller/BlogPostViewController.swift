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
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        let currentBlogPost : BlogPost = blogPosts[indexPath.row]
        cell.bookmarkStar.image = UIImage(systemName: "star")
        cell.postTitle.text = currentBlogPost.title
        cell.postIntroduction.text = currentBlogPost.contents
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
                categoryText += data + "/"
            } else if eName == "pubDate" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
                dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
                let formattedDate = dateFormatter.date(from: data)
                if formattedDate != nil {
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    postDate = dateFormatter.string(from: formattedDate!)
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


