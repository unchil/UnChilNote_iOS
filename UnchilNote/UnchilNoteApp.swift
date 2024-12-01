//
//  UnchilNoteApp.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//

import SwiftUI
import GoogleMaps

@main
struct UnchilNoteApp: App {

	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared
	let setKey = GMSServices.provideAPIKey(KeyVar.GoogleSdkApiKey)

	var body: some Scene {
		WindowGroup {
			ItemListView()
			.environment(\.managedObjectContext, persistenceController.container.viewContext)

		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {

	//By default you want all your views to rotate freely
	static var orientationLock = UIInterfaceOrientationMask.all

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return AppDelegate.orientationLock
	}
}
