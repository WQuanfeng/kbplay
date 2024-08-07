import Flutter
import UIKit
import EZOpenSDKFramework

public class KbplayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kbplay", binaryMessenger: registrar.messenger())
    let instance = KbplayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let factory = Ys7PlatformViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "kbplay/view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = (call.arguments as? NSDictionary) ?? [:]
    print("[KBPlay] \(call.method): \(args)")
    
    switch call.method {
    case "initSDK":
      EZOpenSDK.initLib(withAppKey: args["appKey"] as! String)
      EZOpenSDK.setAccessToken(args["accessToken"] as! String)
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
