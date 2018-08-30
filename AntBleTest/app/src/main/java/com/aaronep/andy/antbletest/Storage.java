package com.aaronep.andy.antbletest;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import java.util.ArrayList;

public class Storage {


    private final static String TAG = Storage.class.getSimpleName();
    private ArrayList<BluetoothDevice> devicesDiscovered = new ArrayList<>();
    private ArrayList<String> deviceAddresses = new ArrayList<>();
    private int storageCounter = 0;

    //private BluetoothDevice device;
    //private String deviceAddress;


    public void setDeviceAddress(String deviceAddress) {
        Log.i(TAG, "setDeviceAddress: ");
        deviceAddresses.add(deviceAddress);
    }

    public void setDevice(BluetoothDevice device) {
        Log.i(TAG, "setDevice: ");
        devicesDiscovered.add(device);
    }

    public ArrayList<String> getDeviceAddresses() {
        Log.i(TAG, "getDeviceAddresses: " + deviceAddresses.size());
        return deviceAddresses;
    }


    public int getStorageCounter() {
        Log.i(TAG, "getStorageCounter: " + storageCounter);
        return storageCounter;
    }

    public void setStorageCounter() {
        storageCounter += 1;
        Log.i(TAG, "setStorageCounter: " + storageCounter);
    }
}
