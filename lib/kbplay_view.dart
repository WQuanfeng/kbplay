import 'dart:io';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kbplay.dart';

class KBPlayView extends StatefulWidget {
  /// EZOpen参数：设备序列号
  final String? deviceSerial;

  /// EZOpen参数：通道号
  final int? cameraNo;

  /// 非 EZOpen 协议播放链接
  final String? url;

  final double? height;

  const KBPlayView({super.key, this.deviceSerial, this.cameraNo, this.url, this.height});

  @override
  State<KBPlayView> createState() => _KBPlayViewState();
}

class _KBPlayViewState extends State<KBPlayView> {
  final ijkplayer = FijkPlayer();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    KBPlay.destroyPlayer();
    ijkplayer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (widget.url?.isNotEmpty == true) {
      ijkplayer.setDataSource(widget.url!, autoPlay: true);
      child = FijkView(player: ijkplayer, fit: FijkFit.cover, color: Colors.black);
    } else if (widget.deviceSerial?.isNotEmpty == true && widget.cameraNo != null) {
      if (Platform.isIOS) {
        child = UiKitView(
          viewType: "kbplay/view",
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) async {
            await KBPlay.createPlayer(deviceSerial: widget.deviceSerial!, cameraNo: widget.cameraNo!);
          },
        );
      } else if (Platform.isAndroid) {
        child = AndroidView(
          viewType: "kbplay/view",
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) async {
            await KBPlay.createPlayer(deviceSerial: widget.deviceSerial!, cameraNo: widget.cameraNo!);
          },
        );
      }
    }

    return Container(height: widget.height ?? 216, color: Colors.black, child: child);
  }
}

class KBPlayController {
  void setVideoSource() {}
}
