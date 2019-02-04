package com.example.virtualcrit30;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;


import no.nordicsemi.android.ble.BleManagerCallbacks;


    public class cscManagerCallbacks implements BleManagerCallbacks {
        private final static String TAG = cscManagerCallbacks.class.getSimpleName();

        /**
         * Called when the Android device started connecting to given device.
         * The {@link #onDeviceConnected(BluetoothDevice)} will be called when the device is connected,
         * or {@link #onError(BluetoothDevice, String, int)} in case of error.
         *
         * @param device the device that got connected.
         */
        @Override
        public void onDeviceConnecting(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceConnecting: " + device.getName());
            Variables.setMessageBarValue(device.getName() + " Connecting");
        }

        /**
         * Called when the device has been connected. This does not mean that the application may start
         * communication.
         * A service discovery will be handled automatically after this call. Service discovery
         * may ends up with calling {@link #onServicesDiscovered(BluetoothDevice, boolean)} or
         * {@link #onDeviceNotSupported(BluetoothDevice)} if required services have not been found.
         *
         * @param device the device that got connected.
         */
        @Override
        public void onDeviceConnected(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceConnected: " + device.getName());
            Variables.setStatusSC(device.getName() + " Connected");
            Variables.setMessageBarValue(device.getName() + " Connected");
        }

        /**
         * Called when user initialized disconnection.
         *
         * @param device the device that gets disconnecting.
         */
        @Override
        public void onDeviceDisconnecting(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceDisconnecting: " + device.getName());
            Variables.setMessageBarValue(device.getName() + " Disconnecting");
        }

//        /**
//         * Called when the device has disconnected (when the callback returned
//         * {@link BluetoothGattCallback#onConnectionStateChange(BluetoothGatt, int, int)} with state
//         * DISCONNECTED), but ONLY if the {@link BleManager#shouldAutoConnect()} method returned false
//         * for this device when it was connecting.
//         * Otherwise the {@link #onLinkLossOccurred(BluetoothDevice)} method will be called instead.
//         *
//         * @param device the device that got disconnected.
//         */
        @Override
        public void onDeviceDisconnected(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceDisconnected: " + device.getName());
            Variables.setMessageBarValue(device.getName() + " Disconnected");

        }

//        /**
//         * This callback is invoked when the Ble Manager lost connection to a device that has been
//         * connected with autoConnect option (see {@link BleManager#shouldAutoConnect()}.
//         * Otherwise a {@link #onDeviceDisconnected(BluetoothDevice)} method will be called on such
//         * event.
//         *
//         * @param device the device that got disconnected due to a link loss.
//         */
        @Override
        public void onLinkLossOccurred(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onLinkLossOccurred: " + device.getName());
            Variables.setMessageBarValue(device.getName() + " onLinkLoss");
        }

        /**
         * Called when service discovery has finished and primary services has been found.
         * This method is not called if the primary, mandatory services were not found during service
         * discovery. For example in the Blood Pressure Monitor, a Blood Pressure service is a
         * primary service and Intermediate Cuff Pressure service is a optional secondary service.
         * Existence of battery service is not notified by this call.
         * <p>
         * After successful service discovery the service will initialize all services.
         * The {@link #onDeviceReady(BluetoothDevice)} method will be called when the initialization
         * is complete.
         *
         * @param device                the device which services got disconnected.
         * @param optionalServicesFound if <code>true</code> the secondary services were also found
         */
        @Override
        public void onServicesDiscovered(@NonNull BluetoothDevice device, boolean optionalServicesFound) {
            Log.i(TAG, "onServicesDiscovered: " + device.getName());
        }

        /**
         * Method called when all initialization requests has been completed.
         *
         * @param device the device that get ready.
         */
        @Override
        public void onDeviceReady(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceReady: " + device.getName());
        }

        /**
         * Called when an {@link BluetoothGatt#GATT_INSUFFICIENT_AUTHENTICATION} error occurred and the
         * device bond state is {@link BluetoothDevice#BOND_NONE}.
         *
         * @param device the device that requires bonding.
         */
        @Override
        public void onBondingRequired(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onBondingRequired: ");
        }

        /**
         * Called when the device has been successfully bonded.
         *
         * @param device the device that got bonded.
         */
        @Override
        public void onBonded(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onBonded: ");
        }

        /**
         * Called when the bond state has changed from {@link BluetoothDevice#BOND_BONDING} to
         * {@link BluetoothDevice#BOND_NONE}.
         *
         * @param device the device that failed to bond.
         */
        @Override
        public void onBondingFailed(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onBondingFailed: ");
        }

        /**
         * Called when a BLE error has occurred
         *
         * @param device    the device that caused an error.
         * @param message   the error message.
         * @param errorCode the error code.
         */
        @Override
        public void onError(@NonNull BluetoothDevice device, @NonNull String message, int errorCode) {
            Log.i(TAG, "onError: " + device.getName());
            Variables.setMessageBarValue(device.getName() + " onError");
        }

        /**
         * Called when service discovery has finished but the main services were not found on the device.
         *
         * @param device the device that failed to connect due to lack of required services.
         */
        @Override
        public void onDeviceNotSupported(@NonNull BluetoothDevice device) {
            Log.i(TAG, "onDeviceNotSupported: ");
        }




    }


