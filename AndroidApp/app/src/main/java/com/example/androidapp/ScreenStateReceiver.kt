package com.example.androidapp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScreenStateReceiver : BroadcastReceiver() {
    //	private UhfReader reader ;
    override fun onReceive(context: Context, intent: Intent) {
        //reader = UhfReader.getInstance();
        //屏亮
        if (intent.action == Intent.ACTION_SCREEN_ON) {
//			UhfReaderDevice.getInstance().powerOn();
//			Log.i("ScreenStateReceiver", "screen on");

//			MainActivity.openGPIO();
        } //屏灭
        else if (intent.action == Intent.ACTION_SCREEN_OFF) {
//			UhfReaderDevice.getInstance().powerOff();
//			Log.i("ScreenStateReceiver", "screen off");
//			MainActivity.closeGPIO();
        }
    }
}