//
//  SettingsTableViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit
import CoreBluetooth

var bpmValue : Int = 0
var bpmAverage:Int = 0;var bpmTotals:Int = 0;var bpmCount:Int = 0;
var bpmEnabled: Bool = false



class SettingsTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var found_peripheral: CBPeripheral?
    var arrPeripheral = [CBPeripheral?]()
    var arr_connected_peripherals = [CBPeripheral?]()
    
    let HR_Service = "0x180D"
    let HR_Char =  "0x2A37"
    let CSC_Service = "0x1816"
    let CSC_Char = "0x2A5B"
    
    
    @IBOutlet weak var valueBluetoothName: UILabel!
    @IBOutlet weak var valueBluetoothStatus: UILabel!
    @IBOutlet weak var valueBluetoothDeviceStatus: UILabel!
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state)")
        
        switch (central.state) {
        case .unknown:
            print("state: unknown")
            break;
        case .resetting:
            print("state: resetting")
            break;
        case .unsupported:
            print("state: unsupported")
            break;
        case .unauthorized:
            print("state: unauthorized")
            break;
        case .poweredOff:
            print("state: power off")
            break;
        case .poweredOn:
            print("state: power on")
            //found_peripheral = nil
            break;
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(indexPath)  indexPath selected")
        print("\(indexPath.section), \(indexPath.row)")
        let cat: String = String(indexPath.section) + String(indexPath.row)
        
        
        switch cat {
        case "00":
            print("case 00")
            
        case "20":
            print("case 20, startBluetooth")
            startBluetooth()
        default:
            print("default")
         
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    
    
    
    
    //didConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        arr_connected_peripherals.append(peripheral)
        peripheral.delegate = self
        print("Looking for Services for \(String(describing: peripheral.name))...")
        peripheral.discoverServices([CBUUID.init(string: HR_Service)])
        //self.BLTE_tableViewOutlet.reloadData()
        valueBluetoothDeviceStatus.text = "CONNECTING..."
        
    }
    
    //didDiscoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered Services!!!")
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                if (service.uuid == CBUUID(string: HR_Service)) {
                    let transferCharacteristicUUID = CBUUID.init(string: HR_Char)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }
                
//                if (service.uuid == CBUUID(string: CSC_Service)) {
//                    let transferCharacteristicUUID = CBUUID.init(string: CSC_Char)
//                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
//                }
            }
        }
    }
    
    //didDiscoverCharacteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: HR_Char) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("didDiscoverChar HR for \(peripheral.name!)")
                    valueBluetoothDeviceStatus.text = "AWAITING DATA"
                }
//                if characteristic.uuid == CBUUID(string: CSC_Char) {
//                    peripheral.setNotifyValue(true, for: characteristic)
//                    print("didDiscoverChar CSC for \(peripheral.name!)")
//                }
            }
        }
    }
    
//    var bpmValue : Int = 0
//    var bpmAverage:Int = 0;var bpmTotals:Int = 0;var bpmCount:Int = 0;
//    var bpmEnabled: Bool = false
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        guard characteristic.value != nil else {
            return
        }
        
        func decodeHRValue(withData data: Data) {
            let count = data.count / MemoryLayout<UInt8>.size
            var array = [UInt8](repeating: 0, count: count)
            (data as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
//            var bpmValue : Int = 0
            if ((array[0] & 0x01) == 0) {
                bpmValue = Int(array[1])
                //hr = stringer(dbl: Double(bpmValue), len: 0)
            } else {
                bpmValue = Int(UInt16(array[2] * 0xFF) + UInt16(array[1]))
                //hr = stringer(dbl: Double(bpmValue), len: 0)
            }
            //usingBTforHeartrate = true
            //current.currentHR = bpmValue
            //current.currentScore = getScoreFromHR(x: Double(current.currentHR))
            //let str: String = "\(current.currentHR):\(stringer(dbl: current.currentScore, len: 0))"
            //out_Btn1.setTitle(str, for: .normal)
            bpmCount += 1
            bpmTotals += bpmValue
            bpmAverage = bpmTotals / bpmCount
            bpmEnabled = true
            
            valueBluetoothStatus.text = "HEARTRATE VALUE: \(bpmValue)"
            
        }
        
        
//        func decodeCSC(withData data : Data) {
//            let WHEEL_REVOLUTION_FLAG               : UInt8 = 0x01
//            let CRANK_REVOLUTION_FLAG               : UInt8 = 0x02
//            let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
//            let flag = value[0]
//            if flag & WHEEL_REVOLUTION_FLAG == 1 {
//                //print("SPD value[1]");print(value[1])
//                if value[1] > 0 {
//                    //out_Btn2.setTitle(String(value[1]), for: .normal)
//                    usingBTforSpeed = true
//                }
//                processWheelData(withData: data)
//                if flag & CRANK_REVOLUTION_FLAG == 2 {
//                    if value[7] > 0 {
//                        //out_Btn3.setTitle(String(value[7]), for: .normal)
//                        usingBTforCadence = true
//                    }
//                    //print("CAD value[7]");print(value[7])
//                    processCrankData(withData: data, andCrankRevolutionIndex: 7)
//                }
//            } else {
//                if flag & CRANK_REVOLUTION_FLAG == 2 {
//                    if value[1] > 0 {
//                        //out_Btn3.setTitle(String(value[1]), for: .normal)
//                        usingBTforCadence = true
//                    }
//                    //print("CAD value[1]");print(value[1])
//                    processCrankData(withData: data, andCrankRevolutionIndex: 1)
//                }
//            }
//        }
        
    
        
        
        
        
        if characteristic.uuid == CBUUID(string: HR_Char) {
            guard characteristic.value != nil else {
                print("Characteristic Value is nil on this go-round")
                return
            }
            if error != nil {
                print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
                return
            }
            decodeHRValue(withData: characteristic.value!)
        }
        
//        if characteristic.uuid == CBUUID(string: CSC_Char) {
//            guard characteristic.value != nil else {
//                print("Characteristic Value is nil on this go-round")
//                return
//            }
//
//            if error != nil {
//                print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
//                return
//            }
//
//            decodeCSC(withData: characteristic.value!)
//        }
    }
    
    
    //didDisconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("Did Disconnect Peripheral")
        // check to see if the peripheral is connected
        print("did disconnect peripheral:  \(String(describing: peripheral.name))")
        valueBluetoothDeviceStatus.text = "DISCONNECTED"
        bpmEnabled = false
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")
            //put rescan code here
            centralManager.connect(peripheral, options: nil)
            //self.BLTE_tableViewOutlet.reloadData()
            return
        }
        
        guard let services = peripheral.services else {
            // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            print("Cancel Peripheral Connection")
            //self.BLTE_tableViewOutlet.reloadData()
            return
        }
        
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    
                    if characteristic.uuid == CBUUID.init(string: HR_Char) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
//                    if characteristic.uuid == CBUUID.init(string: CSC_Char) {
//                        peripheral.setNotifyValue(false, for: characteristic)
//                        print("set Notify Value to False")
//                        return
//                    }
                    
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral)
        print("Cancel Connection")
        //self.BLTE_tableViewOutlet.reloadData()
    }
    
    
    
    
    
    var scanInProgress: Bool = false
    func startBluetooth() {
        print("Starting BLE, Scanning")
        scanInProgress = true
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return
        } else {
//            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: CSC_Service), CBUUID.init(string: HR_Service)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: HR_Service)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            
            valueBluetoothDeviceStatus.text = "SCANNING..."
        }
        
        //self.out_Btn1.setTitle("...", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.centralManager.stopScan()
            print("Stop Scanning")
            //self.out_Btn1.setTitle("RESCAN", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                //self.BLTE_tableViewOutlet.reloadData()
                self.scanInProgress = false
                
                //SHOW DIALOG
                if ((self.found_peripheral) != nil) {
                    print("connecting to peripheral \(String(describing: self.found_peripheral?.name))")
                self.centralManager?.connect(self.found_peripheral!, options: nil)
                    
                //self.valueBluetoothName.text = "\(String(describing: self.found_peripheral!.name))"
                let bn = self.found_peripheral?.name!
                self.valueBluetoothName.text = bn
                self.valueBluetoothDeviceStatus.text = "CONNECTING.."
                    
                    
                } else {
                    print("nothing to connect to")
                    self.valueBluetoothDeviceStatus.text = "NONE FOUND"
                }

                
                
            })
        })
    }
    //end startBluetooth
    
    //discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral:
        CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("didDiscover peripheral \(String(describing: peripheral.name)) at \(RSSI)")
        // check to see if we've already saved a reference to this peripheral
        if let firstSuchElement = arrPeripheral.first(where: { $0 == peripheral }) {
            print("\(String(describing: firstSuchElement?.name)) exists")
        } else {
            found_peripheral = peripheral
            arrPeripheral.append(peripheral)
            //self.BLTE_tableViewOutlet.reloadData()
        }
    }
    

    
    
    
    
            

}
