//
//  AppDelegate.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

// swiftlint:disable line_length

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let nav = UINavigationBar.appearance()
        nav.isTranslucent = true
        nav.backgroundColor = .white
        nav.shadowImage = UIImage()
        nav.setBackgroundImage(.init(), for: .default)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.backgroundColor = .white
        nav.standardAppearance = standardAppearance
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.backgroundColor = .white.withAlphaComponent(0.1)
        nav.scrollEdgeAppearance = scrollEdgeAppearance
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// swiftlint:enable line_length
