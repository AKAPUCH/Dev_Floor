//
//  ConfigurationViewController.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/15.
//

import UIKit
import SnapKit
class ConfigurationViewController: UIViewController {
    
    let buttonView = ButtonView()
    
    lazy var darkmodeSwitch : UISwitch = {
       let settings = UISwitch()
        settings.isUserInteractionEnabled = true
        settings.addTarget(self, action: #selector(onClickSwitch), for: .touchUpInside)
        return settings
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavi()
        setUI()
        addSwitch()
//        swipeRecognizer()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        self.view = buttonView
    }
    
    
    func addSwitch() {
        buttonView.button4.addSubview(darkmodeSwitch)
        darkmodeSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
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
                title = "설정"
    }
    
    func setUI() {
        buttonView.button1.setTitle("목록 설정", for: .normal)
        buttonView.button1.setTitleColor(.label, for: .normal)
        buttonView.button2.setTitle("위젯 설정", for: .normal)
        buttonView.button2.setTitleColor(.label, for: .normal)
        buttonView.button3.setTitle("테마 변경", for: .normal)
        buttonView.button3.setTitleColor(.label, for: .normal)
        buttonView.button4.setTitle("다크 모드", for: .normal)
        buttonView.button4.setTitleColor(.label, for: .normal)
        self.view.accessibilityIgnoresInvertColors = true
        
        
    }
    
    @objc func onClickSwitch(_ sender : UISwitch) {
        if #available(iOS 13.0, *) {
           let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            if sender.isOn {
                print("다크모드")
                windowScene.keyWindow?.overrideUserInterfaceStyle = .dark
                
            } else {
                print("화이트모드")
                windowScene.keyWindow?.overrideUserInterfaceStyle = .light
                
            }
        }
    }
    


    
//    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer){
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction{
//            case UISwipeGestureRecognizer.Direction.right:
//                // 스와이프 시, 원하는 기능 구현.
//                let nextVC = AppInfoViewController()
//                self.present(nextVC, animated: true)
//            default:
//                let nextVC = BookmarkViewController()
//                self.present(nextVC, animated: true)
//            }
//        }
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
