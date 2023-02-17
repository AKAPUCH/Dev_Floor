//
//  AppInfoViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit

class AppInfoViewController: UIViewController {

    let buttonView = ButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavi()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        self.view = buttonView
        setUI()
    }
    
    func setNavi() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithOpaqueBackground()
                navigationController?.navigationBar.standardAppearance = navigationBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
                navigationController?.navigationBar.tintColor = .blue

                navigationItem.scrollEdgeAppearance = navigationBarAppearance
                navigationItem.standardAppearance = navigationBarAppearance
                navigationItem.compactAppearance = navigationBarAppearance

                navigationController?.setNeedsStatusBarAppearanceUpdate()
                
                navigationController?.navigationBar.isTranslucent = false
                navigationController?.navigationBar.backgroundColor = .white
                title = "앱 정보"
    }
    
    func setUI() {
        buttonView.button1.setTitle("버전 정보", for: .normal)
        buttonView.button2.setTitle("리뷰 쓰기 ⭐️⭐️⭐️⭐️⭐️", for: .normal)
        buttonView.button3.setTitle("내 블로그 등록하기", for: .normal)
        buttonView.button4.setTitle("도움주신 분들", for: .normal)
        
        buttonView.button2.setTitleColor(.systemBlue, for: .normal)
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
