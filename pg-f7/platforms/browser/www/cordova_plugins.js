cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/cordova-plugin-ble-central/www/ble.js",
        "id": "cordova-plugin-ble-central.ble",
        "pluginId": "cordova-plugin-ble-central",
        "clobbers": [
            "ble"
        ]
    },
    {
        "file": "plugins/cordova-plugin-ble-central/src/browser/BLECentralPlugin.js",
        "id": "cordova-plugin-ble-central.BLECentralPlugin",
        "pluginId": "cordova-plugin-ble-central",
        "merges": [
            "ble"
        ]
    },
    {
        "file": "plugins/cordova-plugin-device/www/device.js",
        "id": "cordova-plugin-device.device",
        "pluginId": "cordova-plugin-device",
        "clobbers": [
            "device"
        ]
    },
    {
        "file": "plugins/cordova-plugin-device/src/browser/DeviceProxy.js",
        "id": "cordova-plugin-device.DeviceProxy",
        "pluginId": "cordova-plugin-device",
        "runs": true
    },
    {
        "file": "plugins/cordova-plugin-mauron85-background-geolocation/www/backgroundGeolocation.js",
        "id": "cordova-plugin-mauron85-background-geolocation.backgroundGeolocation",
        "pluginId": "cordova-plugin-mauron85-background-geolocation",
        "clobbers": [
            "backgroundGeolocation"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-compat": "1.2.0",
    "cordova-plugin-ble-central": "1.1.4",
    "cordova-plugin-device": "1.1.7",
    "cordova-custom-config": "5.0.1",
    "cordova-plugin-mauron85-background-geolocation": "2.3.3"
}
// BOTTOM OF METADATA
});