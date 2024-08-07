import 'package:flutter/material.dart';
import 'package:kbplay/kbplay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final deviceSerial = "J56830537";
  final cameraNo = 1;

  // final url = "http://cloud.ruiboyun.net/vod/vod3/ndirh7l7/index.m3u8";
  final url =
      "rtmp://rtmp503-online-hzali.lechange.com:12966/live/28de595627d6d45c877af722852d079c2bb9e6395c7e1425&eventLiveID=1462848529";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      await KBPlay.initSDK(
        appKey: "8e09a1954c994e42962e69fa38e04069",
        accessToken: "at.3eonufotcyuf23d7b5sxnx5yab7dkftm-60u5o4t66k-1mquvxt-usu8b5svv",
      );
      // await KBPlay.createPlayer("J56830537", 1);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            const KBPlayView(deviceSerial: "J56830537", cameraNo: 1),

            // KBPlayView(url: url),
            TextButton(
                onPressed: () {
                  KBPlay.startRealPlay();
                },
                child: const Text("开始播放")),
            TextButton(
                onPressed: () {
                  KBPlay.stopRealPlay();
                },
                child: const Text("暂停播放")),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 0, action: 1);
                    },
                    child: const Text("左")),
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 1, action: 1);
                    },
                    child: const Text("右")),
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 2, action: 1);
                    },
                    child: const Text("上")),
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 3, action: 1);
                    },
                    child: const Text("下")),
              ],
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 4, action: 1);
                    },
                    child: const Text("近")),
                TextButton(
                    onPressed: () {
                      KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 5, action: 1);
                    },
                    child: const Text("远")),
              ],
            ),
            TextButton(
                onPressed: () {
                  KBPlay.controlPTZ(deviceSerial: deviceSerial, cameraNo: cameraNo, command: 0, action: 2, speed: 2);
                },
                child: const Text("停止")),
          ],
        ),
      ),
    );
  }
}
