//
//  Ys7PlatformView.swift
//  kbplay
//
//  Created by Wang on 2024/8/5.
//

import Flutter
import Foundation
import EZOpenSDKFramework

class Ys7PlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  var messenger: FlutterBinaryMessenger
  
  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }
  
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
    return Ys7PlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
  }
}

class Ys7PlatformView: NSObject, FlutterPlatformView, EZPlayerDelegate {
  private var _view: UIView
  private var _imgView: UIImageView?
  private var _loadingLabel: UILabel?
  
  var player: EZPlayer?
  var messenger: FlutterBinaryMessenger
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    _view = UIView()
    self.messenger = messenger
    super.init()
    
    initMethodChannel()
  }
  
  func initMethodChannel() {
    let channel = FlutterMethodChannel(name: "kbplay/play", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      let args = (call.arguments as? NSDictionary) ?? [:]
      print("[KBPlay] \(call.method): \(args)")
      
      switch call.method {
      case "createPlayer":
        self.player = EZOpenSDK.createPlayer(withDeviceSerial: args["deviceSerial"] as! String, cameraNo: args["cameraNo"] as! Int)
        
        if let p = self.player {
          p.delegate = self
          p.setPlayerView(self._view)
          
          if self._loadingLabel == nil {
            self._loadingLabel = UILabel(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 30))
            self._loadingLabel?.text = "加载中..."
            self._loadingLabel?.textColor = .white
            self._loadingLabel?.font = UIFont.systemFont(ofSize: 14)
            self._loadingLabel?.textAlignment = .center
            self._view.addSubview(self._loadingLabel!)
          }
          self._loadingLabel?.isHidden = false
          
          p.startRealPlay()
        }
        result(true)
      case "destroyPlayer":
        self.player?.destoryPlayer()
        self.player = nil
        result(true)
      case "startRealPlay":
        let ok = self.player?.startRealPlay()
        result(ok)
      case "stopRealPlay":
        let ok = self.player?.stopRealPlay()
        
        if self._imgView == nil {
          self._imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self._view.frame.width, height: self._view.frame.height))
          self._view.addSubview(self._imgView!)
        }
        self._imgView?.image = self.player?.capturePicture(50)
        
        result(ok)
      case "controlPTZ":
        let cmd = EZPTZCommand(rawValue: 1 << (args["command"] as! Int))
        let act = EZPTZAction(rawValue: args["action"] as! Int) ?? EZPTZAction.stop
        
        EZOpenSDK.controlPTZ(args["deviceSerial"] as! String, cameraNo: args["cameraNo"] as! Int, command: cmd, action: act, speed: args["speed"] as! Int) { err in
          result(err?.localizedDescription)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  func view() -> UIView {
    return _view
  }
  

  func player(_ player: EZPlayer!, didPlayFailed error: (any Error)!) {
    print("[KBPlay] 播放失败\(error.localizedDescription)")
  }
  
  func player(_ player: EZPlayer!, didReceivedMessage messageCode: Int) {
    if (messageCode == EZMessageCode.PLAYER_REALPLAY_START.rawValue) {
      print("[KBPlay] 开始播放")
      _loadingLabel?.isHidden = true
    }
  }
}
