//
//  SettingsTableViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

var bpmValue : Int = 0
var bpmAverage:Int = 0;var bpmTotals:Int = 0;var bpmCount:Int = 0;

var bpmEnabled: Bool = false

var critStatus: Int = 1  //active
var wpts = [CLLocationCoordinate2D]()
var trktps = [CLLocationCoordinate2D]()
var gpxNames = [String]()
var waypointTimesTimString = ""
var tempName: String = "PP"

//settings
var settingsName: String = "TIM"
var settingsActivityType: String = "BIKE"
var settingsAudioStatus: String = "ON"
var settingsSecondsPerRound: Int = 1800
var settingsGpsStatus: String = "ON"
var settingsMaxHR: Int = 185
var settingsLeaderMessage: String = "Nice Try, but you can't beat me."



class SettingsTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIDocumentInteractionControllerDelegate {
    
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
    
    @IBOutlet weak var valueLeaderMessage: UILabel!
    @IBOutlet weak var valueCritBuilderFromMap: UILabel!
    
    @IBOutlet weak var valueNameGPX: UILabel!
    @IBOutlet weak var valueStatusGPX: UILabel!
    
    @IBOutlet weak var valueRiderName: UILabel!
    @IBOutlet weak var valueGpsActive: UILabel!
    @IBOutlet weak var valueAudio: UILabel!
    @IBOutlet weak var valueActivityType: UILabel!
    
    @IBOutlet weak var valueCritID: UILabel!
    
    
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        startTimer()
    }
    
    var timer = Timer()
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        print("SETTINGS Timer Started")
        
            
    }
    func stopTimer() {
        print("SETTINGS Timer Stopped")
        timer.invalidate()
    }
    @objc func timerInterval() {
        //print("SETTINGS TIMER INTERVAL")
        valueStatusGPX.text = raceStatusDisplay
        if (gpxNames.first != nil) {
        valueNameGPX.text = gpxNames.first ?? ""
            if (wpts.count < 2) {
                valueNameGPX.text = "-"
            }
        }
        
        if collectCoordsIsComplete == true {
            collectCoordsInProgress = false
            collectCoordsIsComplete = false
            print("calling critBuilderCollectionComplete")
            critBuilderCollectionComplete()
        }

        
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsTableVC did Load")
        valueRiderName.text = settingsName.uppercased()
        settingsLeaderMessage = "I am \(settingsName). You can't beat me."
        valueLeaderMessage.text = settingsLeaderMessage
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(indexPath)  indexPath selected")
        print("\(indexPath.section), \(indexPath.row)")
        let cat: String = String(indexPath.section) + String(indexPath.row)
        
        
        switch cat {
        case "00":
            print("case 00")
            getNameDialog()
        case "01":
            print("case 01, GPS")
                        if valueGpsActive.text == "ON" {settingsGpsStatus = "OFF";valueGpsActive.text = "OFF";} else {settingsGpsStatus = "ON";valueGpsActive.text = "ON"}
        case "02":
            print("case 02, audio")
            if valueAudio.text == "OFF" {settingsAudioStatus = "ON";valueAudio.text = "ON";print("audioStatus is ON");} else {settingsAudioStatus = "OFF";valueAudio.text = "OFF"}
        case "03":
            print("case 03, activity")
            if (valueActivityType.text == "BIKE") {
                settingsActivityType = "RUN"
                valueActivityType.text = "RUN"
                //showUserTrackingPath = 1
            } else {
                if (valueActivityType.text == "RUN") {
                    settingsActivityType = "ROW";
                    valueActivityType.text = "ROW"
                    //showUserTrackingPath = 2
                } else {
                    settingsActivityType = "BIKE";
                    valueActivityType.text = "BIKE"
                }
            }
            
        case "04":
            print("case 04, show user track")
            showUserTrackingPath = 1

        case "14":
            print("case 14, builder, collectCoordsInProgress: \(collectCoordsInProgress)")
            //CHANGE UI ON CLICK
            
            collectCoordsInProgress = true
            coordsForBuilderCrit.removeAll()
            coordsForBuilderCritNames.removeAll()
            valueCritBuilderFromMap.text = "CLICK HERE WHEN COMPLETE"
            print("CLEAR ARR, COLLECTION HAS STARTED")
            getNameDialogForCB()
//
//
//            if collectCoordsInProgress == true {
//                //is true, set to false
////                print("set to false")
////                collectCoordsInProgress = false
//                //COLLECT FINISHED, CREATE THE CRIT
//                //CREATE NAMES AND WPTS...
////                print("COLLECT FINISHED, CREATE THE CRIT")
//                //valueCritBuilderFromMap.text = "COLLECTION COMPLETE"
////                critBuilderCollectionComplete()
//                //CHANGE LOGIC, USE TIMER TO CHECK VAR AND AUTO CHANGE TAB ON FINISH DIALOG
//            } else {
//                //is false, set to true
//                print("set to true")
//
//                collectCoordsInProgress = true
//                coordsForBuilderCrit.removeAll()
//                coordsForBuilderCritNames.removeAll()
//                valueCritBuilderFromMap.text = "CLICK HERE WHEN COMPLETE"
//                print("CLEAR ARR, COLLECTION HAS STARTED")
//                getNameDialogForCB()
//            }
            

        case "15":
            print("case 15, change leader message")
            getLeaderMessageDialog()
            
            
        case "16":
            print("case 16, startSim")
            //useSimRide = true
            
        case "12":
            print("case 12, load GPX")
            useSimRide = false
            getGPX()
        case "13":
            print("case 13, get critid")
            getCritId()
        case "20":
            print("case 20, startBluetooth")
            startBluetooth()
        case "40":
            print("case 40, launch T&C")
            UIApplication.shared.openURL(URL(string: "https://www.virtualcrit.com/tandc.html")!)
        default:
            print("default")
         
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    var docController:UIDocumentInteractionController!
    
    func critBuilderCollectionComplete() {
//        coordsForBuilderCrit
        print("critBuilderCollectionComplete")
        let numberOfLocations = coordsForBuilderCrit.count
        if numberOfLocations < 2 {return}
        
        //clear old
        wpts.removeAll()
        gpxNames.removeAll()
        llPoints = ""
        llNames = ""
        
        for n in coordsForBuilderCritNames {
            gpxNames.append(n)
            llNames = "\(llNames)\(n),"
        }
        
        //var i: Int = 1
        for c in coordsForBuilderCrit {
            wpts.append(c)
            
            //if cbName.count == 0 {return}
//            if i == 1 {
//                gpxNames.append(self.cbName)
//                llNames = "\(self.cbName),"
//            } else {
//                gpxNames.append("Checkpoint")
//                llNames = "\(llNames)Checkpoint,"
//            }
            llPoints = "\(llPoints)\(c.latitude),\(c.longitude):"
            
//            i += 1
        }
        
        //gpxNames[gpxNames.count-1] = "FINISH"
        
//        print("llNames: \(llNames)")
//        print("llPoints: \(llPoints)")

        if llPoints.last! == ":" {
            llPoints = String(llPoints.dropLast())
        }
        if llNames.last! == "," {
            llNames = String(llNames.dropLast())
        }
        //llNames = llNames + " FINISH"
        
        
        print("llNames -  \(llNames)")
        print("llPoints -  \(llPoints)")
        
        if gpxNames.count == 0 {return}
        
        if (gpxNames.first != nil) {
//            addValueToTimelineString(s: "RACE LOADED:\n\(gpxNames.first ?? "")\nPROCEED TO START\n")

            tempName = gpxNames.first!
            if (tempName.count > 0) {
                valueCritBuilderFromMap.text = "CRIT BUILDER (FROM MAP)"
            }
            
            valueNameGPX.text = tempName
            loadedRaceName = tempName
            valueStatusGPX.text = "AWAITING ARRIVAL"
            
            critStatus = 105
        }
        

    }
    
    
    
    func getCritId() {
        let alertController = UIAlertController(title: "CRIT ID", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let name = alertController.textFields?[0].text
            
            tempName = name!.uppercased()
            self.valueCritID.text = "CRIT ID (ENTER CRIT ID)"
            
            print("critid:  \(tempName)")
            
            self.valueNameGPX.text = tempName
            self.valueStatusGPX.text = "AWAITING ARRIVAL"
            loadedRaceName = tempName
            print("critStatus is 100, after getCritId")
            critStatus = 100
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "..."
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //START GET CB NAME
    var cbName = ""
    func getNameDialogForCB() {
        
        let alertController = UIAlertController(title: "STARTING CRIT BUILDER", message: "TO ENTER CHECKPOINTS, HOLD YOUR FINGER ON EACH POINT ON THE MAP UNTIL MARKER APPEARS.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            self.valueCritBuilderFromMap.text = "CRIT BUILDER STARTED"
            
            //change to map tab
            self.tabBarController?.selectedIndex = 0
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
//        alertController.addTextField { (textField) in
//            textField.placeholder = "CRIT NAME"
//        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getLeaderMessageDialog() {
        
        let alertController = UIAlertController(title: "LEADER MESSAGE", message: "OTHERS WILL HEAR IF THEY FAIL TO DEFEAT YOU.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let ld = alertController.textFields?[0].text
            self.valueLeaderMessage.text = ld!
            settingsLeaderMessage = ld!
            print("settingsLeaderMessage:  \(settingsLeaderMessage)")
            UserDefaults.standard.set(settingsLeaderMessage, forKey: "udLeaderMessage")
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = settingsLeaderMessage
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //END GET CB NAME
    func getNameDialog() {
        
        let alertController = UIAlertController(title: "Rider Name", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let name = alertController.textFields?[0].text
            self.valueRiderName.text = name!.uppercased()
            settingsName = name!.uppercased()
            print("riderName:  \(settingsName)")
            UserDefaults.standard.set(settingsName, forKey: "udName")

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = settingsName
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func getGPX() {
        print("getGPX")
        currentCritPoint = 0
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.xml","xml"], in: .import)
        importMenu.delegate = (self as UIDocumentMenuDelegate)
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true, completion: nil)
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

            }
        }
    }
    
    
    
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

            bpmCount += 1
            bpmTotals += bpmValue
            bpmAverage = bpmTotals / bpmCount
            bpmEnabled = true
            
            valueBluetoothStatus.text = "HEARTRATE VALUE: \(bpmValue)"
            
        }
        
        
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
                    
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral)
        print("Cancel Connection")
    }
    
    
    
    
    
    var scanInProgress: Bool = false
    func startBluetooth() {
        print("Starting BLE, Scanning")
        scanInProgress = true
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return
        } else {
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: HR_Service)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            valueBluetoothDeviceStatus.text = "SCANNING..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.centralManager.stopScan()
            print("Stop Scanning")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.scanInProgress = false
                
                if ((self.found_peripheral) != nil) {
                    print("connecting to peripheral \(String(describing: self.found_peripheral?.name))")
                self.centralManager?.connect(self.found_peripheral!, options: nil)
                    
                //self.valueBluetoothName.text = "\(String(describing: self.found_peripheral!.name))"
                let bn = self.found_peripheral?.name!
                self.valueBluetoothName.text = bn
                self.valueBluetoothDeviceStatus.text = "CONNECTING.."
                    addValueToTimelineString(s: "Connecting to \(bn!)")
//                    addValueToTimelineString(s: "Connecting to \(String(describing: bn)).")
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
            self.arrPeripheral.append(peripheral)
            let bn = peripheral.name!
            let alertController = UIAlertController(title: "\(bn)", message: "", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Connect", style: .default) { (_) in
                print("connect")
                self.found_peripheral = peripheral
                //self.arrPeripheral.append(peripheral)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                print("cancel")
            }
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
//            found_peripheral = peripheral
//            arrPeripheral.append(peripheral)

        }
    }
    


    var gpxName = ""
    var currentParsingElement:String = ""
    
    
}

extension SettingsTableViewController: UIDocumentMenuDelegate, UIDocumentPickerDelegate, XMLParserDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        /// Handle your document
        print("did pick document at url:  \(url)")
        
        if let parser = XMLParser(contentsOf: url) {
            parser.delegate = self
            parser.parse()
        }
    }
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overCurrentContext
        present(documentPicker, animated: true, completion: nil)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("doc picker cancelled")
    }
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentParsingElement = elementName
        
        if elementName == "gpx" {
            
            wpts = []
            trktps = []
            //trktps.first is the start point
            gpxNames = []
            
            llNames = ""
            llPoints = ""
            
            valueStatusGPX.text = "LOADING"
            valueNameGPX.text = "..."
        }
        
        if elementName == "wpt" {
            //Create a World map coordinate from the file
            let lat = attributeDict["lat"]!
            let lon = attributeDict["lon"]!
            
            print("wpt, \(lat), \(lon)")
            print("add points to mid")
            llPoints = "\(llPoints)\(lat),\(lon):"
            wpts.append(CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lon)!))
        }
        
        if elementName == "trkpt" {
            //Create a World map coordinate from the file
            let lat = attributeDict["lat"]!
            let lon = attributeDict["lon"]!
            
            print("trkpt, \(lat), \(lon)")
            trktps.append(CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lon)!))
        }
        
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let foundedChar = string.trimmingCharacters(in:NSCharacterSet.whitespacesAndNewlines)
        
        if (!foundedChar.isEmpty) {
            if currentParsingElement == "name" {
                gpxName = foundedChar
                gpxNames.append(gpxName.uppercased())
                print("gpxName:  \(gpxName.uppercased())")
                

            }

        }
        
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" {
            print("Ended parsing name...")
            print("Last in gpxnames: \(String(describing: gpxNames.last?.uppercased()))")
        }
        
        if elementName == "gpx" {
            if gpxNames.count > 0 {
            valueNameGPX.text = gpxNames.last?.uppercased()
            valueStatusGPX.text = "AWAITING ARRIVAL"
                
            //update arrays
                let lastName = gpxNames.last?.uppercased()  //which is the route name
            gpxNames.insert(lastName ?? "NONE", at: 0)

            gpxNames.removeLast()
            
            gpxNames.append("FINISH LINE")
                
            let firstCoords = trktps.first
            wpts.insert(firstCoords!, at: 0)
                llPoints = "\(wpts.first!.latitude),\(wpts.first!.longitude):\(llPoints)"
 
            let lastCoords = trktps.last
                wpts.append(lastCoords!)
                llPoints = "\(llPoints)\(wpts.last!.latitude),\(wpts.last!.longitude)"

            print("gpxNames \(gpxNames) \n\n\n")
                for na: String in gpxNames {
                    llNames = "\(llNames)\(na.uppercased()),"
                }
                
            print("llNames \(llNames)")
            print("llPoints \(llPoints)")
                if (gpxNames.first != nil) {
                    addValueToTimelineString(s: "\(gpxNames.first ?? "") IS LOADED.")
                    loadedRaceName = "\(gpxNames.first ?? ""))"
                    critStatus = 105
                    print("critStatus is 105, after loading GPX file")
                }
                

            }

        }
    }
    
    
}
