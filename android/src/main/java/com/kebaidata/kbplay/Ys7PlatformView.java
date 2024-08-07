package com.kebaidata.kbplay;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.videogo.exception.BaseException;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;


public class Ys7PlatformView implements PlatformView, MethodChannel.MethodCallHandler, Handler.Callback {
    @NonNull private final SurfaceView view;
    @NonNull private final ImageView imageView;
    @NonNull private final TextView loadingText;
    @NonNull private final BinaryMessenger messenger;
    @Nullable private EZPlayer player;

    Ys7PlatformView(@NonNull Context context, int viewId, @Nullable Object creationParams, @NonNull BinaryMessenger messenger) {
        view = new SurfaceView(context);
        imageView = new ImageView(context);

        loadingText = new TextView(context);
        loadingText.setText("加载中...");
        loadingText.setTextColor(Color.WHITE);
        loadingText.setTextSize(14);

        this.messenger = messenger;

        initMethodChannel();
    }

    @NonNull
    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {
        if (this.player != null) {
            this.player.setSurfaceHold(null);
            this.player.release();
        }
        this.player = null;
    }

    public void initMethodChannel() {
        MethodChannel channel = new MethodChannel(this.messenger, "kbplay/play");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        System.out.println("[KBPlay] " + call.method + ": " + (call.arguments == null ? "{}" : call.arguments.toString()));

        String deviceSerial = call.argument("deviceSerial");
        Integer cameraNo = call.argument("cameraNo");
        boolean ok = false;

        switch (call.method) {
            case "createPlayer":
                this.player = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
                ok = this.player.setSurfaceHold(this.view.getHolder());
                if (ok) {
                    this.player.setHandler(new Handler(this));

                    loadingText.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT, Gravity.CENTER));
                    ((ViewGroup) view.getParent()).addView(loadingText);

                    this.player.startRealPlay();
                }
                result.success(ok);
                break;
            case "destroyPlayer":
                if (this.player != null) {
                    this.player.setSurfaceHold(null);
                    this.player.release();
                }
                this.player = null;
                result.success(true);
                break;
            case "startRealPlay":
                if (this.player != null) {
                    ok = this.player.startRealPlay();
                }
                result.success(ok);
                break;
            case "stopRealPlay":
                if (this.player != null) {
                    ok = this.player.stopRealPlay();

                    if (imageView.getParent() == null) {
                        imageView.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
                        ((ViewGroup) view.getParent()).addView(imageView);
                    }

                    imageView.setVisibility(View.VISIBLE);
                    imageView.setImageBitmap(this.player.capturePicture());
                }
                result.success(ok);
                break;
            case "controlPTZ":
                new Thread(() -> {
                    try {
                        int cmd = call.argument("command");
                        int act = call.argument("action");
                        int speed = call.argument("speed");

                        boolean ptz = EZOpenSDK.getInstance().controlPTZ(
                                deviceSerial,
                                cameraNo,
                                EZConstants.EZPTZCommand.values()[cmd],
                                act == 1 ? EZConstants.EZPTZAction.EZPTZActionSTART : EZConstants.EZPTZAction.EZPTZActionSTOP,
                                speed
                        );
                        result.success(ptz ? null : "控制失败");
                    } catch (BaseException e) {
                        result.success(e.toString());
                    }
                }).start();
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public boolean handleMessage(@NonNull Message message) {
        switch (message.what) {
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_START:
                System.out.println("[KBPlay] 播放开始");
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                loadingText.setVisibility(View.INVISIBLE);
                imageView.setVisibility(View.INVISIBLE);
                System.out.println("[KBPlay] 播放成功");
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_STOP_SUCCESS:
                System.out.println("[KBPlay] 暂停成功");
                break;
            case EZConstants.EZRealPlayConstants.MSG_PTZ_SET_SUCCESS:
                System.out.println("[KBPlay] 云台控制成功");
                break;
            case EZConstants.EZRealPlayConstants.MSG_PTZ_SET_FAIL:
                System.out.println("[KBPlay] 云台控制失败");
                break;
            default:
                break;
        }
        return false;
    }
}
