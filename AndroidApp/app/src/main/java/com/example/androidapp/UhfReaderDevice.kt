package com.example.androidapp

import android.serialport.api.SerialPort

class UhfReaderDevice {
    fun powerOn() {
//    devPower.psampoweron();
    }

    fun powerOff() {
        if (devPower != null) {
//		devPower.psampoweroff();
            devPower = null
        }
    }

    companion object {
        private var readerDevice: UhfReaderDevice? = null
        private var devPower: SerialPort? = null
        val instance: UhfReaderDevice?
            get() {
                if (devPower == null) {
                    try {
                        devPower = SerialPort()
                    } catch (e: Exception) {
                        return null
                    }
                }
                if (readerDevice == null) {
                    readerDevice = UhfReaderDevice()
                }
                return readerDevice
            }
    }
}