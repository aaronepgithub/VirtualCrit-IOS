cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
  {
    "id": "cordova-plugin-ble-central.ble",
    "file": "plugins/cordova-plugin-ble-central/www/ble.js",
    "pluginId": "cordova-plugin-ble-central",
    "clobbers": [
      "ble"
    ]
  },
  {
    "id": "cordova-plugin-device.device",
    "file": "plugins/cordova-plugin-device/www/device.js",
    "pluginId": "cordova-plugin-device",
    "clobbers": [
      "device"
    ]
  }
];
module.exports.metadata = 
// TOP OF METADATA
{
  "cordova-custom-config": "5.0.1",
  "cordova-plugin-ble-central": "1.1.4",
  "cordova-plugin-device": "1.1.7"
};
// BOTTOM OF METADATA
});