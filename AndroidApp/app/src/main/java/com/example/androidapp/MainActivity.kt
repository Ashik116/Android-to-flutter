package com.example.androidapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import androidx.activity.ComponentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import android.app.Activity
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color

import android.util.Log
import android.view.KeyEvent
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.Window
import android.widget.AdapterView
import android.widget.AdapterView.OnItemClickListener

import android.widget.ListView
import android.widget.TextView
import android.zyapi.CommonApi
import com.qs.uhf.uhfreaderlib.reader.EPC
import com.qs.uhf.uhfreaderlib.reader.Tools
import com.qs.uhf.uhfreaderlib.reader.UhfReader
import com.qs.uhf.uhfreaderlib.reader.UhfReaderDevice
import io.flutter.plugin.common.MethodChannel

private const val FLUTTER_ENGINE_ID = "module_flutter_engine"

class MainActivity : ComponentActivity()  {

    private var readerDevice // 读写器设备，抓哟操作读写器电源
            : UhfReaderDevice? = null
    private var screenReceiver: ScreenStateReceiver? = null

    lateinit var flutterEngine : FlutterEngine

    internal inner class InventoryThread(private val channel: MethodChannel) : Thread() {
        private var epcList: List<ByteArray>? = null
       var runFlag=true

        override fun run() {
            super.run()
            while (runFlag) {
                if (startFlag) {
                    epcList = reader!!.inventoryRealTime() // 实时盘存
                    if (epcList != null && !epcList!!.isEmpty()) {
                        // 播放提示音
                        // player.start();
                        for (epc in epcList!!) {
                            if (epc != null) {
                                val epcStr = Tools.Bytes2HexString(
                                    epc,
                                    epc.size
                                )
                               // addToList(listEPC, epcStr)
                                print(epcStr)
                                // epcStr = Tools.Bytes2HexString(epc, epc.size)
                                channel.invokeMethod("receiveEPCString", epcStr)
                            }
                        }
                    }
                    epcList = null
                    try {
                        sleep(40)
                    } catch (e: InterruptedException) {
                        // TODO Auto-generated catch block
                        //  e.printStackTrace()
                    }
                }
            }
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)


        serialPortPath = "/dev/ttyMT2"
        mCommonApi = CommonApi()
        openGPIO()
        try {
            Thread.sleep(2000)
        } catch (e1: InterruptedException) {
            // TODO Auto-generated catch block
            e1.printStackTrace()
        }

        UhfReader.setPortPath(serialPortPath)
        reader = UhfReader.getInstance()

//        Toast.makeText(MainActivity.this, "" + reader.getPortPath(), Toast.LENGTH_SHORT).show();

        //设为欧洲频段
        reader?.setWorkArea(3)



        readerDevice = UhfReaderDevice.getInstance()
        if (reader == null) {
            return
        }
        if (readerDevice == null) {
            return
        }
        try {
            Thread.sleep(100)
        } catch (e: InterruptedException) {
            // TODO Auto-generated catch block
            e.printStackTrace()
        }
        // 获取用户设置功率,并设置
        val shared = getSharedPreferences("power", 0)
        val value = shared.getInt("value", 100)
        Log.d("", "value$value")
        reader!!.setOutputPower(value)

        // powerOn=true;
        // 添加广播，默认屏灭时休眠，屏亮时唤醒
        screenReceiver = ScreenStateReceiver()
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_SCREEN_ON)
        filter.addAction(Intent.ACTION_SCREEN_OFF)
        val CHANNEL = "getEPC"
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        val thread: Thread = InventoryThread(methodChannel)
        thread.start()



        // Instantiate a FlutterEngine
        flutterEngine = FlutterEngine(this)

        // Start executing Dart code to pre-warm the FlutterEngine
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )


        // Cache the FlutterEngine to be used by FlutterActivity
        FlutterEngineCache
            .getInstance()
            .put(FLUTTER_ENGINE_ID, flutterEngine)

        val myButton = findViewById<Button>(R.id.myButton)
        myButton.setOnClickListener {
            startActivity(
                FlutterActivity
                    .withCachedEngine(FLUTTER_ENGINE_ID)
                    .build(this)
            )
        }
    }
    companion object {
        private var buttonStart: Button? = null
        var startFlag = true
        private var serialPortPath = "/dev/ttyS1"
        var reader // 超高频读写器
                : UhfReader? = null
        var mCommonApi: CommonApi? = null
        private const val mComFd = -1

        // 打开gpio
        fun openGPIO() {
            // TODO Auto-generated method stub
            mCommonApi!!.setGpioDir(78, 1)
            mCommonApi!!.setGpioOut(78, 1)
            mCommonApi!!.setGpioDir(83, 1)
            mCommonApi!!.setGpioOut(83, 1)
            mCommonApi!!.setGpioDir(68, 1)
            mCommonApi!!.setGpioOut(68, 1)

//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 1);
          //  buttonStart!!.setText(R.string.inventory)
        }

        // 关闭gpio
        fun closeGPIO() {
            mCommonApi!!.setGpioDir(78, 1)
            mCommonApi!!.setGpioOut(78, 0)
            mCommonApi!!.setGpioDir(83, 1)
            mCommonApi!!.setGpioOut(83, 0)

//        mCommonApi.setGpioDir(86, 1);
//        mCommonApi.setGpioOut(86, 0);
        }
    }

}

