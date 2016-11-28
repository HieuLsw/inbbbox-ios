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

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {

        AnalyticsManager.setupAnalytics()
        CrashManager.setup()
        UserStorage.clearGuestUser()
        CacheManager.setupCache()
        UIAlertController.setupSharedSettings()
        configureInitialSettings()
        
        centerButtonTabBarController = CenterButtonTabBarController()
        loginViewController = LoginViewController(tabBarController: centerButtonTabBarController!)
        let rootViewController = UserStorage.isUserSignedIn ? centerButtonTabBarController! : loginViewController!
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        
        ColorModeProvider.setup()

        var shouldPerformAdditionalDelegateHandling = true
        if let shortcut = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            launchedShortcut = shortcut
            shouldPerformAdditionalDelegateHandling = false
        }

        return shouldPerformAdditionalDelegateHandling
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        // NGRTodo: start loading images from Dribbble,
        // but first, check if notificationID == currentUserID
    }

    func application(application: UIApplication,
                     didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let notificationName = NotificationKey.UserNotificationSettingsRegistered.rawValue
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcut else { return }

        handleShortcutItem(shortcut)
        launchedShortcut = nil
    }

    func application(application: UIApplication,
                     performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
                                                  completionHandler: (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem)
        completionHandler(handledShortcutItem)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL? = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask)
        return urls.last
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("StoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory?.URLByAppendingPathComponent("StoreData.sqlite")

        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: url,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                          NSInferMappingModelAutomaticallyOption: true])
        } catch {
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {

        if let sourceApplication = options["UIApplicationOpenURLOptionsSourceApplicationKey"] {

            if String(sourceApplication) == "com.apple.SafariViewService" {

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

    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {

        guard UserStorage.isUserSignedIn else { return false }

        var handled = false
        if let shortcut = Shortcut(rawValue: shortcutItem.type) {
            typealias index = CenterButtonTabBarController.CenterButtonViewControllers
            switch shortcut {
            case .Likes:
                centerButtonTabBarController?.selectedIndex = index.Likes.rawValue
            case .Buckets:
                centerButtonTabBarController?.selectedIndex = index.Buckets.rawValue
            case .Shots:
                centerButtonTabBarController?.selectedIndex = index.Shots.rawValue
            case .Followees:
                centerButtonTabBarController?.selectedIndex = index.Followees.rawValue
            }
            centerButtonTabBarController?.configureForLaunchingWithForceTouchShortcut()
            handled = true
        }

        return handled
    }
}
