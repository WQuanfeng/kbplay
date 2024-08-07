package com.kebaidata.kbplay;

import android.app.Application;

import androidx.annotation.NonNull;

import com.videogo.openapi.EZOpenSDK;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** KbplayPlugin */
public class KbplayPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Application application;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "kbplay");
    channel.setMethodCallHandler(this);

    application = (Application) flutterPluginBinding.getApplicationContext();

    final Ys7PlatformViewFactory factory = new Ys7PlatformViewFactory(flutterPluginBinding.getBinaryMessenger());
    flutterPluginBinding
            .getPlatformViewRegistry()
            .registerViewFactory("kbplay/view", factory);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    System.out.println("[KBPlay] " + call.method + ": " + call.arguments.toString());

    if (call.method.equals("initSDK")) {
      String appKey = call.argument("appKey");
      String accessToken = call.argument("accessToken");

      EZOpenSDK.initLib(application, appKey);
      EZOpenSDK.getInstance().setAccessToken(accessToken);
      result.success(true);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
