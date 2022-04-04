import UIKit
import Branch
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // if you are using the TEST key
  Branch.setUseTestBranchKey(true)
  // listener for Branch Deep Link data
  Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
       // do stuff with deep link data (nav to page, display content, etc)
      print(params as? [String: AnyObject] ?? {})
  }
  return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Branch.getInstance().application(app, open: url, options: options)
}

func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
  // handler for Universal Links
    return Branch.getInstance().continue(userActivity)
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  // handler for Push Notifications
  Branch.getInstance().handlePushNotification(userInfo)
} }
