package com.pyrotech.loto_soft_java.websocket;

/**
 * Created by chen0 on 10/12/2017.
 */

public interface StompMessageListener {
    void onMessage(StompMessage message);
}
