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

import java.util.LinkedList;
import java.util.UUID;

import no.nordicsemi.android.ble.BleManager;
import no.nordicsemi.android.ble.callback.DataReceivedCallback;
import no.nordicsemi.android.ble.data.Data;

public class hrManager extends BleManager<hrManagerCallbacks> {

    private final static String TAG = hrManager.class.getSimpleName();
    private hrManagerCallbacks hrCB;

    private static final UUID CSC_SERVICE_UUID = UUID.fromString("00001816-0000-1000-8000-00805f9b34fb");
    private static final UUID CSC_CHARACTERISTIC_UUID = UUID.fromString("00002a5b-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805f9b34fb");
    private static final UUID HR_CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805f9b34fb");
    private static final UUID BTLE_NOTIFICATION_DESCRIPTOR_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    private BluetoothGattCharacteristic hrCharacteristic;
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


    public hrManager(@NonNull Context context, BluetoothDevice b) {
        super(context);
        Log.i(TAG, "hrManager: init");

        hrCB = new hrManagerCallbacks();
        setGattCallbacks(hrCB);

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
        return mGattCallback;
    }


    private static final byte HEART_RATE_VALUE_FORMAT = 0x01; // 1 bit
    private static final byte SENSOR_CONTACT_STATUS = 0x06; // 2 bits
    private static final byte ENERGY_EXPANDED_STATUS = 0x08; // 1 bit
    private static final byte RR_INTERVAL = 0x10; // 1 bit

    private final DataReceivedCallback hrData = new DataReceivedCallback() {
        @Override
        public void onDataReceived(@NonNull BluetoothDevice device, @NonNull Data data) {
            //Log.i(TAG, "onDataReceived: ");

            final Data d = data;
            int offset = 0;
            final int flags = d.getIntValue(Data.FORMAT_UINT8, offset++);
            final boolean value16bit = (flags & HEART_RATE_VALUE_FORMAT) > 0;
            int heartRateValue = data.getIntValue(value16bit ? Data.FORMAT_UINT16 : Data.FORMAT_UINT8, offset++); // bits per minute

            final StringBuilder builder = new StringBuilder();
            builder.append(heartRateValue).append(" HR");

            adviseActivity(String.valueOf(builder));
        }

    };

    public void adviseActivity(String s){
        Log.i(TAG, "adviseActivity: " + s);
        try {
            Intent i = new Intent("MESSAGE");
            i.putExtra("msg", s);
            i.putExtra("type", "hr");
            getContext().sendBroadcast(i);

        } catch (Exception e) {
            System.out.print(e);
        }
    }


    private static final byte WHEEL_REVOLUTIONS_DATA_PRESENT = 0x01; // 1 bit
    private static final byte CRANK_REVOLUTION_DATA_PRESENT = 0x02; // 1 bit

    private final DataReceivedCallback cscData = new DataReceivedCallback() {
        @Override
        public void onDataReceived(@NonNull BluetoothDevice device, @NonNull Data data) {
            Log.i(TAG, "onDataReceived: MIO, cscData");

            final Data d = data;

            byte[] value = d.getValue();
//            final int flags = characteristic.getValue()[0]; // 1 byte
            final int flags = value[0]; // 1 byte

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

    private final BleManagerGattCallback mGattCallback = new BleManagerGattCallback() {

        @Override
        protected void initialize() {
            Log.i(TAG, "initialize  BleManagerGattCallback mGattCallback");
            setNotificationCallback(hrCharacteristic).with(hrData);
            enableNotifications(hrCharacteristic).enqueue();

            Log.i(TAG, "initialize  BleManagerGattCallback mGattCallback MIO");
            setNotificationCallback(cscCharacteristic).with(cscData);
            enableNotifications(cscCharacteristic).enqueue();
        }

        @Override
        public boolean isRequiredServiceSupported(@NonNull final BluetoothGatt gatt) {
            Log.i(TAG, "isRequiredServiceSupported: ");

            final BluetoothGattService service = gatt.getService(HR_SERVICE_UUID);
            if (service != null) {
                hrCharacteristic = service.getCharacteristic(HR_CHARACTERISTIC_UUID);
            }

            final BluetoothGattService serviceMio = gatt.getService(CSC_SERVICE_UUID);
            if (serviceMio != null) {
                cscCharacteristic = serviceMio.getCharacteristic(CSC_CHARACTERISTIC_UUID);
            }


            Boolean b = Boolean.TRUE;
            return b;

        }

        @Override
        protected void onDeviceDisconnected() {
            Log.i(TAG, "onDeviceDisconnected: " + getBluetoothDevice().getName());
            adviseActivityMessageBar("onDeviceDisconnected:  " + getBluetoothDevice().getName());
        }
    };

    private void onWheelMeasurementReceived(final int wheelRevolutionValue, final int wheelRevolutionTimeValue) {


        Boolean hasSpeed = CalcSpeed.calcSpeed(wheelRevolutionValue, wheelRevolutionTimeValue);

        if (hasSpeed == Boolean.TRUE) {

            Log.i(TAG, "onWheelMeasurementReceived: HAS SPEED");
            adviseActivitySPD(Variables.getSpeed(), Variables.getDistance(), Variables.getAvgSpeed());


        } else {
            Log.i(TAG, "onWheelMeasurementReceived: NO SPEED");
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

            Log.i(TAG, "onWheelMeasurementReceived: HAS CADENCE");
            adviseActivityCAD(Variables.getCadence());


        } else {
            Log.i(TAG, "onWheelMeasurementReceived: NO CADENCE");
            //return;
        }

    }
//    END CAD CALC

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

