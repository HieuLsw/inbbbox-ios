//
//  AppDelegate.swift
//  Inbbbox
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import CoreData
import Haneke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var centerButtonTabBarController: CenterButtonTabBarController?
    var loginViewController: LoginViewController?
    var launchedShortcut: UIApplicationShortcutItem?

    enum Shortcut: String {
        case Likes = "co.netguru.inbbbox.likes"
        case Buckets = "co.netguru.inbbbox.buckets"
        case Shots = "co.netguru.inbbbox.shots"
        case Followees = "co.netguru.inbbbox.followees"
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AnalyticsManager.setupAnalytics()
        CrashManager.setup()
        UserStorage.clearGuestUser()
        CacheManager.setupCache()
        UIAlertController.setupSharedSettings()
        configureInitialSettings()
        
        centerButtonTabBarController = CenterButtonTabBarController()
        loginViewController = LoginViewController(tabBarController: centerButtonTabBarController!)
        let rootViewController = UserStorage.isUserSignedIn ? centerButtonTabBarController! : loginViewController!
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        
        ColorModeProvider.setup()

        var shouldPerformAdditionalDelegateHandling = true
        if let shortcut = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcut = shortcut
            shouldPerformAdditionalDelegateHandling = false
        }

        return shouldPerformAdditionalDelegateHandling
    }

    func application(_ application: UIApplication,
                     didRegister notificationSettings: UIUserNotificationSettings) {
        let notificationName = NotificationKey.UserNotificationSettingsRegistered.rawValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let shortcut = launchedShortcut else { return }

        _ = handleShortcutItem(shortcut)
        launchedShortcut = nil
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                                                  completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL? = {
        let urls = FileManager.default.urls(for: .documentDirectory,
                in: .userDomainMask)
        return urls.last
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "StoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory?.appendingPathComponent("StoreData.sqlite")

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                          NSInferMappingModelAutomaticallyOption: true])
        } catch {
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
}

// MARK: Initial configuration

private extension AppDelegate {

    func configureInitialSettings() {
        if !Settings.StreamSource.IsSet {
            Settings.StreamSource.PopularToday = true
            Settings.StreamSource.IsSet = true
            Settings.Customization.ShowAuthor = true
        }
    }
}

// MARK: Safari OAuth

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {

        if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {

            if (sourceApplication == "com.apple.SafariViewService") {

                if UserStorage.isGuestUser {
                    let settingsViewController = centerButtonTabBarController?.settingsViewController
                    settingsViewController?.handleOpenURL(url)
                } else {
                    loginViewController?.handleOpenURL(url)
                }

                return true
            }
        }
        return false
    }
}

// MARK: 3D Touch Support

extension AppDelegate {

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {

        guard UserStorage.isUserSignedIn else { return false }

        var handled = false
        if let shortcut = Shortcut(rawValue: shortcutItem.type) {
            typealias index = CenterButtonTabBarController.CenterButtonViewControllers
            switch shortcut {
            case .Likes:
                centerButtonTabBarController?.selectedIndex = index.likes.rawValue
            case .Buckets:
                centerButtonTabBarController?.selectedIndex = index.buckets.rawValue
            case .Shots:
                centerButtonTabBarController?.selectedIndex = index.shots.rawValue
            case .Followees:
                centerButtonTabBarController?.selectedIndex = index.followees.rawValue
            }
            centerButtonTabBarController?.configureForLaunchingWithForceTouchShortcut()
            handled = true
        }

        return handled
    }
}
