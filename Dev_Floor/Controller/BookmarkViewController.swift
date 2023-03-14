//
//  BookmarkViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit
import CoreData
final class BookmarkViewController: UIViewController {
    
    private var webView : WebviewPost? = nil
    private let tableView = UITableView()
    var container : NSPersistentContainer!
    var thing = BlogPost()
    var blogPosts: [BlogPost] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavi()
        setTable()
        setConstraints()
        getContainer()
        selectData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewData), name: NSNotification.Name(rawValue: "ReloadTableViewData1"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    // MARK: - 코어 데이터 관련
    func getContainer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
    }
    
    
    func selectData() {
        blogPosts.removeAll()
        do{
            let contact = try self.container.viewContext.fetch(OldPost.fetchRequest())
            //배열형태로 불러온 데이터
            for bookmarkedPost in contact {
                let bookmarkedBlog = BlogPost()
                bookmarkedBlog.date  = bookmarkedPost.date
                bookmarkedBlog.category  = bookmarkedPost.category
                bookmarkedBlog.link  = bookmarkedPost.link
                bookmarkedBlog.title  = bookmarkedPost.title
                bookmarkedBlog.contents = bookmarkedPost.contents
                blogPosts.append(bookmarkedBlog)
            }
        }catch {
            print(error.localizedDescription)
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
                title = "즐겨찾기"
    }

    @objc func reloadTableViewData() {
        tableView.reloadData()
    }

}

extension BookmarkViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        guard blogPosts.count != 0 else {return cell}
        let currentBlogPost : BlogPost = blogPosts[indexPath.row]
        cell.bookmarkStar.image = UIImage(systemName: "star.fill")
        cell.postTitle.text = currentBlogPost.title
//        cell.postIntroduction.text = change
        return cell
    }
    
    
}

extension BookmarkViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            webView = WebviewPost()
            webView?.blogPostURL = URL(string: blogPosts[indexPath.row].link ?? "www.naver.com")
            navigationController?.pushViewController(webView!, animated: true)
        
    }
    
}
