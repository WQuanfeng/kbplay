import 'package:flutter/services.dart';

export 'kbplay_view.dart';

class KBPlay {
  static const sdkChannel = MethodChannel("kbplay");
  static const playChannel = MethodChannel("kbplay/play");

  /// 初始化SDK
  static Future<bool> initSDK({required String appKey, required String accessToken}) async {
    return await sdkChannel.invokeMethod("initSDK", {"appKey": appKey, "accessToken": accessToken});
  }

  /// 创建播放器
  static Future<bool> createPlayer({required String deviceSerial, required int cameraNo}) async {
    return await playChannel.invokeMethod("createPlayer", {"deviceSerial": deviceSerial, "cameraNo": cameraNo});
  }

  /// 销毁播放器，若使用KBPlayView，会自动销毁
  static Future<bool> destroyPlayer() async {
    return await playChannel.invokeMethod("destroyPlayer");
  }

  /// 开始播放
  static Future<bool> startRealPlay() async {
    return await playChannel.invokeMethod("startRealPlay");
  }

  /// 暂停播放
  static Future<bool> stopRealPlay() async {
    return await playChannel.invokeMethod("stopRealPlay");
  }

  /// deviceSerial: 设备序列号，cameraNo：通道号，
  /// command：左-0、右-1、上-2、下-3、近-4、远-5，
  /// action：1-开始、2-停止，speed：0-慢、1-适中、2-快
  static Future<String?> controlPTZ({
    required String deviceSerial,
    required int cameraNo,
    required int command,
    required int action,
    int speed = 1,
  }) async {
    return await playChannel.invokeMethod("controlPTZ", {
      "deviceSerial": deviceSerial,
      "cameraNo": cameraNo,
      "command": command,
      "action": action,
      "speed": speed,
    });
  }
}
