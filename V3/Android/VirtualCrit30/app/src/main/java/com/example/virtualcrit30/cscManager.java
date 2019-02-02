package com.example.virtualcrit30;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;

import java.util.UUID;

import no.nordicsemi.android.ble.BleManager;
import no.nordicsemi.android.ble.callback.DataReceivedCallback;
import no.nordicsemi.android.ble.data.Data;

public class cscManager extends BleManager<cscManagerCallbacks> {

    private final static String TAG = cscManager.class.getSimpleName();
    private cscManagerCallbacks cscCB;

    private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    private BluetoothGattCharacteristic cscCharacteristic;


//    /**
//     * The manager constructor.
//     * <p>
//     * After constructing the manager, the callbacks object must be set with
//     * {@link #setGattCallbacks(BleManagerCallbacks)}.
//     * <p>
//     * To connect a device, call {@link #connect(BluetoothDevice)}.
//     *
//     * @param context the context.
//     **/


    public cscManager(@NonNull Context context, BluetoothDevice b) {
        super(context);
        Log.i(TAG, "cscManager: init");

        cscCB = new cscManagerCallbacks();
        setGattCallbacks(cscCB);
        connect(b)
                .retry(3, 100)
                .useAutoConnect(true)
                .enqueue();
    }



    /**
     * This method must return the gatt callback used by the manager.
     * This method must not create a new gatt callback each time it is being invoked, but rather
     * return a single object.
     *
     * @return The gatt callback object.
     */
    @NonNull
    @Override
    protected BleManagerGattCallback getGattCallback() {
        Log.i(TAG, "getGattCallback");
        return mGattCallbackCSC;
    }

//    private static final byte HEART_RATE_VALUE_FORMAT = 0x01; // 1 bit
//    private static final byte SENSOR_CONTACT_STATUS = 0x06; // 2 bits
//    private static final byte ENERGY_EXPANDED_STATUS = 0x08; // 1 bit
//    private static final byte RR_INTERVAL = 0x10; // 1 bit

    private static final byte WHEEL_REVOLUTIONS_DATA_PRESENT = 0x01; // 1 bit
    private static final byte CRANK_REVOLUTION_DATA_PRESENT = 0x02; // 1 bit

    private final DataReceivedCallback cscData = new DataReceivedCallback() {

        @Override
        public void onDataReceived(@NonNull BluetoothDevice device, @NonNull Data data) {
            //Log.i(TAG, "onDataReceived: CSC");
            final Data d = data;

            byte[] value = d.getValue();
//            Log.i(TAG, "onDataReceived: d:  " + d.toString());
//            Log.i(TAG, "onDataReceived: value[0]:  " + value[0]);
//            Log.i(TAG, "onDataReceived: value:  " + value);

            final int flags = value[0]; // 1 byte

            Log.i(TAG, "onDataReceived: flags:  " + flags);

            final boolean wheelRevPresent = (flags & WHEEL_REVOLUTIONS_DATA_PRESENT) > 0;
            final boolean crankRevPresent = (flags & CRANK_REVOLUTION_DATA_PRESENT) > 0;

            if (wheelRevPresent) {

                final int cumulativeWheelRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
                final int lastWheelEventReadValue = (value[5] & 0xff) | ((value[6] & 0xff) << 8);

                @SuppressLint("DefaultLocale") final String wString = String.valueOf(cumulativeWheelRevolutions);
                onWheelMeasurementReceived(cumulativeWheelRevolutions, lastWheelEventReadValue);


                if (crankRevPresent) {
                    final int cumulativeCrankRevolutions = (value[7] & 0xff) | ((value[8] & 0xff) << 8);
                    final int lastCrankEventReadValue = (value[9] & 0xff) | ((value[10] & 0xff) << 8);
                    onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
                }
            } else {
                if (crankRevPresent) {
                    final int cumulativeCrankRevolutions = (value[1] & 0xff) | ((value[2] & 0xff) << 8);
                    final int lastCrankEventReadValue = (value[3] & 0xff) | ((value[4] & 0xff) << 8);
                    onCrankMeasurementReceived(cumulativeCrankRevolutions, lastCrankEventReadValue);
                }
            }

        }
    };



    private final BleManagerGattCallback mGattCallbackCSC = new BleManagerGattCallback() {

        @Override
        protected void initialize() {
            Log.i(TAG, "initialize  BleManagerGattCallback mGattCallbackCSC");
            setNotificationCallback(cscCharacteristic).with(cscData);
            enableNotifications(cscCharacteristic).enqueue();
        }

        @Override
        public boolean isRequiredServiceSupported(@NonNull final BluetoothGatt gatt) {
            Log.i(TAG, "isRequiredServiceSupported: ");

            final BluetoothGattService service = gatt.getService(CSC_SERVICE_UUID);
            if (service != null) {
                cscCharacteristic = service.getCharacteristic(CSC_CHARACTERISTIC_UUID);
            }

            Boolean b = Boolean.TRUE;
            return b;

        }


        @Override
        protected void onDeviceDisconnected() {
            Log.i(TAG, "onDeviceDisconnected: " + getBluetoothDevice());
            adviseActivityMessageBar("onDeviceDisconnected:  " + getBluetoothDevice().getName());
        }


    };



    private void onWheelMeasurementReceived(final int wheelRevolutionValue, final int wheelRevolutionTimeValue) {

        Boolean hasSpeed = CalcSpeed.calcSpeed(wheelRevolutionValue, wheelRevolutionTimeValue);

        if (hasSpeed == Boolean.TRUE) {

            //Log.i(TAG, "onWheelMeasurementReceived: HAS SPEED");
            adviseActivitySPD(Variables.getSpeed(), Variables.getDistance(), Variables.getAvgSpeed());


        } else {
            //Log.i(TAG, "onWheelMeasurementReceived: NO SPEED");
            //return;
        }

    }  //END WHEEL CALC




    private void adviseActivitySPD(String s, String d, String a){
        try {
            Intent i = new Intent("MESSAGE");
            i.putExtra("msg", s);
            i.putExtra("type", "spd");
            i.putExtra("distance", d);
            i.putExtra("avgspeed", a);
            getContext().sendBroadcast(i);

            Variables.setDistance(d);
            Variables.setAvgSpeed(a);

        } catch (Exception e) {
            System.out.print(e);
        }


    }

    private void onCrankMeasurementReceived(final int crankRevolutionValue, final int crankRevolutionTimeValue) {


        Boolean hasCadence = CalcCadence.calcCadence(crankRevolutionValue, crankRevolutionTimeValue);

        if (hasCadence == Boolean.TRUE) {

            //Log.i(TAG, "onCrankMeasurementReceived: HAS CADENCE");
            adviseActivityCAD(Variables.getCadence());


        } else {
            //Log.i(TAG, "onCrankMeasurementReceived: NO CADENCE");
            //return;
        }


    }
    //END CAD CALC

    private void adviseActivityCAD(String s){
        try {
            Intent ii = new Intent("MESSAGE");
            ii.putExtra("msg", s);
            ii.putExtra("type", "cad");
            getContext().sendBroadcast(ii);

        } catch (Exception e) {
            System.out.print(e);
        }
    }

    private void adviseActivityMessageBar(String s){
        try {
            Intent ii = new Intent("MESSAGE");
            ii.putExtra("msg", s);
            ii.putExtra("type", "messageBar");
            getContext().sendBroadcast(ii);
        } catch (Exception e) {
            System.out.print(e);
        }
    }



    private int do16BitDiff(int a, int b) {
        if (a >= b)
            return a - b;
        else
            return (a + 65536) - b;
    }




}
