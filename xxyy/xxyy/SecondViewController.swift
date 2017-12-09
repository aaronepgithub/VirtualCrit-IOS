//
//  SecondViewController.swift
//  xxyy
//
//  Created by aaronep on 10/25/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit
import CoreBluetooth

extension UIViewController {

    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)

        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}



class SecondViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var centralManager: CBCentralManager!
    var found_peripheral: CBPeripheral?
    var arrPeripheral = [CBPeripheral?]()
    var arr_connected_peripherals = [CBPeripheral?]()
    var arr_hr_notifying_peripherals = [CBPeripheral?]()
    var arr_CSC_notifying_peripherals = [CBPeripheral?]()
    var arr_updating_values = [String?]()
    
    let HR_Service = "0x180D"
    let HR_Char =  "0x2A37"
    
    let CSC_Service = "0x1816"
    let CSC_Char = "0x2A5B"
    
    var startTime: NSDate?
    
    var roundStartTime: NSDate?
    var roundWheelRevs_atStart: Double = 0
    var roundCrankRevs_atStart: Double = 0
    
    var inRoundSpeed: Double = 0
    var arrRoundSpeeds = [Double]()
    
    var inRoundCadence: Double = 0
    var arrRoundCadences = [Double]()
    
    func newRound() {
        arrRoundSpeeds.append(inRoundSpeed)
        arrRoundCadences.append(inRoundCadence)
        dump(arrRoundSpeeds)
        roundStartTime = NSDate()
        roundWheelRevs_atStart = totalWheelRevs
        roundCrankRevs_atStart = totalCrankRevs
        
        out_Btn1.setTitle(stringer1(myIn: arrRoundSpeeds.last!), for: .normal)
        
        if arrRoundSpeeds.count > 1 {
            out_Btn2.setTitle(stringer1(myIn: arrRoundSpeeds[arrRoundSpeeds.count - 2]), for: .normal)
        }
        
        if arrRoundSpeeds.count > 2 {
            out_Btn3.setTitle(stringer1(myIn: arrRoundSpeeds[arrRoundSpeeds.count - 3]), for: .normal)
        }
        
        if arrRoundSpeeds.count > 3 {
            out_Btn4.setTitle(stringer1(myIn: arrRoundSpeeds[arrRoundSpeeds.count - 4]), for: .normal)
        }
        
    }
    
    func roundUpdate_each_second() {
        let x = NSDate()
        let y = x.timeIntervalSince(roundStartTime! as Date!)
        let z = Int(y)
        
        let a = totalWheelRevs - roundWheelRevs_atStart
        let b = Double(Double(wheelCircumference) / Double(1000)) * 0.000621371
        let c = Double(z) / Double(60) / Double(60)
        inRoundSpeed = Double(a) * Double(b) / Double(c)
        
        let d = Double(totalCrankRevs - roundCrankRevs_atStart)
        inRoundCadence = d / (Double(z) * 60)
        
//        let currentDateTime = Date()
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .none
//        let currTime = formatter.string(from: currentDateTime)
        
        //print(createTimeString(seconds: z), inRoundSpeed, inRoundCadence, currTime)
        
        if z >= 300 {
            newRound()
        }
    }
    
    
    @objc func UpdateTimeDisplay() {  //each second
        let x = NSDate()
        let y = x.timeIntervalSince(startTime! as Date!)
        let z = Double(y)  //time in seconds
        
        rt.string_elapsed_time = createTimeString(seconds: Int(z))
        rt.int_elapsed_time = Int(z)  //int for seconds
        
        roundUpdate_each_second()
        
        NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
        
        //END OF EACH SECOND UPDATE
    }

    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var out_Top1: UIButton!
    @IBOutlet weak var out_Top2: UIButton!
    @IBOutlet weak var out_Top3: UIButton!
    
    
    
    @IBOutlet weak var BLTE_TableViewOutlet: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrPeripheral.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseID1") as! BLTE_TableViewCell

        let str = arrPeripheral[indexPath.row]?.name
        var strr: String = String(describing: arrPeripheral[indexPath.row]!.identifier)
        
        switch(arrPeripheral[indexPath.row]!.state) {
        case .connected:
            strr = "Connected"
        case .disconnected:
            strr = "Disconnected"
        case .connecting:
            strr = "Connecting"
        case .disconnecting:
            strr = "Disconnecting"
        }
        
        cell.BLTE_CellTitle.text = str
        cell.BLTE_CellSubTitle.text = String(describing: strr)
            
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager?.connect(arrPeripheral[indexPath.row]!, options: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        self.BLTE_TableViewOutlet.reloadData()
    }
    
    

    @IBAction func act_Btn1(_ sender: UIButton) {
    }
    
    @IBAction func act_Btn2(_ sender: UIButton) {

        
    }
    
    @IBAction func act_Btn3(_ sender: UIButton) {
        // reset timer start
        //startTime = NSDate()
        //raw_wheel_time_for_avg = 0  //reset ble moving speed
        //raw_wheel_revs_for_avg = 0
        //quick_avg.lap_time = 0
        
    }
    
    @IBAction func act_Btn4(_ sender: UIButton) {
        //let mySavedPeripherals = defaults.stringArray(forKey: "Saved_Peripherals") ?? ["None"]
        //print(mySavedPeripherals)
    }
    
    @IBAction func act_Btn5(_ sender: UIButton) {
        
        //unpress button?
        self.dismiss(animated: true, completion: nil)

    }
    


    @IBOutlet weak var out_Btn1: UIButton!
    @IBOutlet weak var out_Btn2: UIButton!
    @IBOutlet weak var out_Btn3: UIButton!
    @IBOutlet weak var out_Btn4: UIButton!
    @IBOutlet weak var out_Btn5: UIButton!
    
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        arr_connected_peripherals.append(peripheral)
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        peripheral.delegate = self
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
        print("Looking for Services for \(String(describing: peripheral.name))...")
        peripheral.discoverServices([CBUUID.init(string: HR_Service), CBUUID.init(string: CSC_Service)])
        
        self.BLTE_TableViewOutlet.reloadData()
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered Services!!!")
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                // If we found either the transfer service, discover the transfer characteristic
                if (service.uuid == CBUUID(string: HR_Service)) {
                    let transferCharacteristicUUID = CBUUID.init(string: HR_Char)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }

                if (service.uuid == CBUUID(string: CSC_Service)) {
                    let transferCharacteristicUUID = CBUUID.init(string: CSC_Char)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }
            }
        }
    }
    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: HR_Char) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("didDiscoverChar HR for \(peripheral.name!)")
                    arr_hr_notifying_peripherals.append(peripheral)
                }
                if characteristic.uuid == CBUUID(string: CSC_Char) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("didDiscoverChar CSC for \(peripheral.name!)")
                    arr_CSC_notifying_peripherals.append(peripheral)
                }
            }
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral:
        CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("didDiscover peripheral \(String(describing: peripheral.name)) at \(RSSI)")
        // check to see if we've already saved a reference to this peripheral
        
        if let firstSuchElement = arrPeripheral.first(where: { $0 == peripheral }) {
            print("\(String(describing: firstSuchElement?.name)) exists")
        } else {
            found_peripheral = peripheral
            arrPeripheral.append(peripheral)
            self.BLTE_TableViewOutlet.reloadData()
        }
    }
    
    func startScanning() {
        print("Started Scanning")

        
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return
        } else {
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: CSC_Service), CBUUID.init(string: HR_Service)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
     
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.centralManager.stopScan()
            print("Stop Scanning")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.BLTE_TableViewOutlet.reloadData()
            })
        })

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
            var bpmValue : Int = 0
            
            
            if ((array[0] & 0x01) == 0) {
                bpmValue = Int(array[1])
                
            } else {
                //Convert Endianess from Little to Big
                bpmValue = Int(UInt16(array[2] * 0xFF) + UInt16(array[1]))
            }
            rt.rt_hr = Double(bpmValue)
            out_Top1.setTitle(String(bpmValue), for: .normal)
            //out_Btn1.setTitle(String(bpmValue), for: .normal)

        }
        

        func decodeCSC(withData data : Data) {
            let WHEEL_REVOLUTION_FLAG               : UInt8 = 0x01
            let CRANK_REVOLUTION_FLAG               : UInt8 = 0x02
            let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
            //dump(value)
            let flag = value[0]
            
            if flag & WHEEL_REVOLUTION_FLAG == 1 {
                //print("SPD value[1]");print(value[1])
                //out_Btn2.setTitle(String(value[1]), for: .normal)
                processWheelData(withData: data)
                if flag & CRANK_REVOLUTION_FLAG == 2 {
                    //out_Btn3.setTitle(String(value[7]), for: .normal)
                    //print("CAD value[7]");print(value[7])
                    processCrankData(withData: data, andCrankRevolutionIndex: 7)
                }
            } else {
                if flag & CRANK_REVOLUTION_FLAG == 2 {
                    //out_Btn3.setTitle(String(value[1]), for: .normal)
                    //print("CAD value[1]");print(value[1])
                    processCrankData(withData: data, andCrankRevolutionIndex: 1)
                }
            }
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
        
        if characteristic.uuid == CBUUID(string: CSC_Char) {
            guard characteristic.value != nil else {
                print("Characteristic Value is nil on this go-round")
                return
            }
            
            if error != nil {
                print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
                return
            }
            
            decodeCSC(withData: characteristic.value!)
            //print("didUpdateValue for:  \(peripheral.name!).\nService is:  \(characteristic.service.uuid).\nCharacteristic is:  \(characteristic.uuid).")
            
        }
        
        
        
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("Did Disconnect Peripheral")
        
        
//        guard let peripheral = self.found_peripheral else {
//            print("Peripheral object has not been created yet.")
//            return
//        }
        
//        let x = peripheral
//        print(x.name as Any)
        
//        // check to see if the peripheral is connected
//        if x.state != .connected {
//            print("Peripheral exists but is not connected.")
//            //put rescan code here
//            centralManager.connect(x, options: nil)
//            self.BLTE_TableViewOutlet.reloadData()
//            return
//        }
        
        // check to see if the peripheral is connected
        print("did disconnect peripheral:  \(String(describing: peripheral.name))")
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")
            //put rescan code here
            centralManager.connect(peripheral, options: nil)
            self.BLTE_TableViewOutlet.reloadData()
            return
        }
        
        guard let services = peripheral.services else {
            // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            print("Cancel Peripheral Connection")
            self.BLTE_TableViewOutlet.reloadData()
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
                    if characteristic.uuid == CBUUID.init(string: CSC_Char) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
                    
                }
            }
        }
        centralManager.cancelPeripheralConnection(peripheral)
        print("Cancel Connection")
        self.BLTE_TableViewOutlet.reloadData()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state)")
        
        // if Bluetooth is on, proceed...
        if central.state != .poweredOn {
            found_peripheral = nil
            return
        }
        
        // check for a peripheral object
        //        guard let peripheral = found_peripheral else {
        //            return
        //        }
        
        //        // see if that peripheral is connected
        //        guard peripheral.state == .connected else {
        //            return
        //        }
        
        self.BLTE_TableViewOutlet.reloadData()
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("refresh fctn")
        startScanning()
        refreshControl.endRefreshing()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    var mainTimer = Timer()
    var rtTimer = Timer()
    var returnSpeed: Double = 0
    var returnCadence: Double = 0
    
    @objc func Update_rtTimer() {
        returnSpeed = get_rt_speed_and_distance()
        out_Top3.setTitle(stringer1(myIn: returnSpeed), for: .normal)
        returnCadence = get_rt_cadence()
        out_Top2.setTitle(stringer0(myIn: returnCadence), for: .normal)
        
//        print("Speed")
//        dump(arr_srs)
//        print("Cadence")
//        dump(arr_src)
    }
    
    //have to restart on settings change
    func start_rtTimer() {
        rtTimer = Timer()
        rtTimer = Timer.scheduledTimer(timeInterval: rtTimer_Interval, target: self, selector: #selector(Update_rtTimer), userInfo: nil, repeats: true)
        print("Start rt Timer")
        
        roundStartTime = NSDate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.BLTE_TableViewOutlet.addSubview(refreshControl)
        
        if rt.int_elapsed_time == 0 {
            mainTimer = Timer()
            mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimeDisplay), userInfo: nil, repeats: true)
            startTime = NSDate()
            print("Start Main Timer")
            start_rtTimer()
        }
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

