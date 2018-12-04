//
//  AppDelegate.swift
//  Testing
//
//  Created by Anders Ha on 04/12/2018.
//  Copyright © 2018 babylonhealth. All rights reserved.
//

import UIKit
import StyleSheets
import Bento
import BentoKit
import ReactiveSwift

let image = UIImage(named: "Hello")!
let component = Component.TitledDescription(
    texts: [
        TextValue.plain("Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 Text 1 "),
        TextValue.plain("Text 2 Text 2 Text 2 Text 2 Text 2 Text 2 Text 2 Text 2 Text 2"),
        TextValue.plain("Text 3 Text 3 Text 3 Text 3 Text 3 Text 3 Text 3 Text 3 Text 3 Text 3 Text 3"),
        TextValue.plain("Text 4 Text 4 Text 4 Text 4 Text 4 Text 4 Text 4 Text 4 Text 4 Text 4")
    ],
    detail: TextValue.plain("Detail"),
    image: Property(value: ImageOrLabelView.Content.image(image)),
    accessory: Component.TitledDescription.Accessory.checkmark,
    isEnabled: true,
    didTap: {
        print("didTap")
},
    didTapAccessory: {
        print("didTapAccessory")
},
    deleteAction: .action(title: "Delete") {
        print("didDelete")
    },
    styleSheet: Component.TitledDescription.StyleSheet(
        textStyles: [
            .init(),
            .init(),
            .init(),
            .init()
        ])
        .compose(\.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        .compose(\.imageOrLabel.fixedSize, CGSize(width: 100, height: 100))
)

class StubVM: BoxViewModel {
    let state = Property<Void>(value: ())

    func send(action: Void) {}
}

struct StubAppearance: BoxAppearance {
    var traits: UITraitCollection = .init()
}

struct StubRenderer: BoxRenderer {
    let component: Component.TitledDescription

    init(observer: @escaping (Void) -> (), appearance: StubAppearance, config: Component.TitledDescription) {
        component = config
    }

    func render(state: Void) -> Screen<Int, Int> {
        return Screen(title: "", box: .empty
            |-+ Section(id: 0)
            |---+ Node(id: 0, component: component)
            |---+ Node(id: 1, component: component)
            |---+ Node(id: 2, component: component)
            |---+ Node(id: 3, component: component)
            |---+ Node(id: 4, component: component)
            |---+ Node(id: 5, component: component)
        )
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        let vc = BoxViewController.init(viewModel: StubVM(), renderer: StubRenderer.self, rendererConfig: component, appearance: Property(value: StubAppearance()))
        window!.rootViewController = vc
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

