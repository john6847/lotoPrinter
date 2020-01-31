package com.pyrotech.loto_soft_java;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import com.pyrotech.loto_soft_java.websocket.SpringBootWebSocketClient;
import com.pyrotech.loto_soft_java.websocket.StompMessage;
import com.pyrotech.loto_soft_java.websocket.StompMessageListener;
import com.pyrotech.loto_soft_java.websocket.TopicHandler;
import com.sunmi.printerhelper.utils.AidlUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.stream.Stream;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.lotorb.print/printer";
    private static final String CHANNEL_ENTERPRISEID = "com.lotorb.bloked/enterprise";
    private static final String CHANNEL_POSID = "com.lotorb.bloked/pos";
    private static final String CHANNEL_WEBSOCKET = "com.lotorb.print/configuration";

    public static Charset charset = Charset.forName("UTF-8");
    String configuration = "";

    private boolean isAidl;

    public boolean isAidl() {
        return isAidl;
    }

    public void setAidl(boolean aidl) {
        isAidl = aidl;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        isAidl = true;
        AidlUtil.getInstance().connectPrinterService(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("printer")) {
                        AidlUtil.getInstance().initPrinter();
                        AidlUtil.getInstance().printText(call.argument("bets").toString(), 25, false, false);
                    }
        });

        new MethodChannel(getFlutterView(), CHANNEL_ENTERPRISEID).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("enterprise")) {
                        String WEBSOCKET_URL_EVENT = "";
                        System.out.println("*************** "+call.argument("enterpriseId"));
                        WEBSOCKET_URL_EVENT = "/topics/"+call.argument("enterpriseId")+"/event";
                        System.out.println(WEBSOCKET_URL_EVENT);
                        receiveMessage(WEBSOCKET_URL_EVENT);
                        result.success(5);
                    }
                });

        new MethodChannel(getFlutterView(), CHANNEL_POSID).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("pos")) {
                        String WEBSOCKET_URL_EVENT = "";
                        System.out.println("*************** "+call.argument("posId"));
                        WEBSOCKET_URL_EVENT = "/topics/"+call.argument("enterpriseId")+"/"+call.argument("posId")+"/event";
                        System.out.println(WEBSOCKET_URL_EVENT);
                        receiveMessage(WEBSOCKET_URL_EVENT);
                        result.success(5);
                    }
                });


    }


    public void receiveMessage(String eventUrl){
        SpringBootWebSocketClient client = new SpringBootWebSocketClient();

        TopicHandler handler = client.subscribe(eventUrl);

        handler.addListener(new StompMessageListener() {
            @Override
            public void onMessage(StompMessage message) {
                configuration = message.getContent();
                System.out.println(message.toString());

                final Handler handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        BasicMessageChannel basicMessageChannel =
                                new BasicMessageChannel<String>(getFlutterView(),"foo",StringCodec.INSTANCE);
                        basicMessageChannel.send(configuration);
                    }
                });
            }
        });
//        http://www.lotosof.com:3200/
        client.connect("ws://lotosof.com:3200/my-ws/websocket");
    }


    public static ByteBuffer str_to_bb(String msg, Charset charset){
        return ByteBuffer.wrap(msg.getBytes(charset));
    }

}
