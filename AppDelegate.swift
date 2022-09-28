import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let videoChatChannel = FlutterMethodChannel(name: "efamilycare_opentok",
                                                    binaryMessenger: controller as! FlutterBinaryMessenger)
        videoChatChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "openVideoChat":
                self?.presentVideoChatScreen(result: result, params: call.arguments as! [String])
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func presentVideoChatScreen(result: @escaping FlutterResult, params: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = "VideoChatNavigationViewController"
        let navVC = storyboard.instantiateViewController(withIdentifier: identifier) as! UINavigationController
        let videoChatVC = navVC.viewControllers.first as! VideoChatViewController
        videoChatVC.onCloseTap = { callDuration in
            result("\(callDuration) seconds")
        }
        videoChatVC.kApiKey = params[0]
        videoChatVC.kSessionId = params[1]
        videoChatVC.kToken = params[2]
        window.rootViewController?.present(navVC, animated: true, completion: nil)
    }
    
}
