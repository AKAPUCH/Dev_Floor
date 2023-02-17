//
//  SceneDelegate.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        // MARK: - UINavigationController 구현
        
        
        // MARK: - UITabBar구현
        let tabVC = UITabBarController()
        let tab1 = UINavigationController(rootViewController: BlogPostViewController())
        let tab2 = UINavigationController(rootViewController:BookmarkViewController())
        let tab3 = UINavigationController(rootViewController:ConfigurationViewController())
        let tab4 = UINavigationController(rootViewController:AppInfoViewController())
        
        tab1.title = "목록"
        tab2.title = "즐겨찾기"
        tab3.title = "설정"
        tab4.title = "앱 정보"
        tabVC.setViewControllers([tab1,tab2,tab3,tab4], animated: false)
        tabVC.modalPresentationStyle = .fullScreen
        tabVC.tabBar.backgroundColor = .white
        
        guard let items = tabVC.tabBar.items else {return}
        
        items[0].image = UIImage(systemName: "list.star")
        items[1].image = UIImage(systemName: "list.bullet.circle")
        items[2].image = UIImage(systemName: "gearshape.fill")
        items[3].image = UIImage(systemName: "ellipsis")
        window?.rootViewController = tabVC
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

