package com.example.virtualcrit30;

import android.bluetooth.BluetoothDevice;

import java.util.ArrayList;

public final class Devices {

    private final static String TAG = Devices.class.getSimpleName();

    private static ArrayList<BluetoothDevice> devicesDiscoveredHR = new ArrayList<>();
    private static ArrayList<BluetoothDevice> devicesDiscoveredCSC = new ArrayList<>();
    private static ArrayList<BluetoothDevice> devicesConnectedHR = new ArrayList<>();
    private static ArrayList<BluetoothDevice> devicesConnectedCSC = new ArrayList<>();


    public static ArrayList<BluetoothDevice> getDevicesDiscoveredHR() {
        return devicesDiscoveredHR;
    }

    public static void setDevicesDiscoveredHR(ArrayList<BluetoothDevice> devicesDiscoveredHR) {
        Devices.devicesDiscoveredHR = devicesDiscoveredHR;
    }

    public static ArrayList<BluetoothDevice> getDevicesDiscoveredCSC() {
        return devicesDiscoveredCSC;
    }

    public static void setDevicesDiscoveredCSC(ArrayList<BluetoothDevice> devicesDiscoveredCSC) {
        Devices.devicesDiscoveredCSC = devicesDiscoveredCSC;
    }

    public static BluetoothDevice getSpecificDeviceHR(int i) {
        return devicesDiscoveredHR.get(i);
    }

    public static BluetoothDevice getSpecificDeviceCSC(int i) {
        return devicesDiscoveredCSC.get(i);
    }
}
