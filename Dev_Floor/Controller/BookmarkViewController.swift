//
//  BookmarkViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit

final class BookmarkViewController: UIViewController {

    private let tableView = UITableView()
    
    var thing = BlogPost()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavi()
        setTable()
        setConstraints()
        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BookmarkViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! ListTableViewCell
        cell.bookmarkStar.image = UIImage(systemName: "star.fill")
        cell.postTitle.text = "테스트 제목"
        cell.postIntroduction.text = "테스트 내용은 다음과 같습니다"
        return cell
    }
    
    
}

extension BookmarkViewController : UITableViewDelegate {

}
