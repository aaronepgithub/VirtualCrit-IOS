//
//  SecondViewController.swift
//  xxyy
//
//  Created by aaronep on 10/25/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit
import CoreBluetooth



extension UIAlertController {
    
    func presentInOwnWindow(animated: Bool, completion: (() -> Void)?) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
}

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

extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: minutes, to: self)!
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
    var roundGeoDistance: Double = 0
    var inRoundSpeed: Double = 0
    var inRoundCadence: Double = 0
    var inRoundHR: Double = 0
    var totalAvgHR: Double = 0
    var inRoundGeoDist: Double = 0
    var inRoundGeoSpeed: Double = 0
    
    func newRoundActionSheet() {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "ROUND COMPLETE", preferredStyle: .actionSheet)
        
        let a1 = UIAlertAction(title: "SPD:  \(stringer2(myIn: round.speeds.last!))  MPH", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let a2 = UIAlertAction(title: "HRT:  \(stringer1(myIn: round.heartrates.last!))  BPM", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let a3 = UIAlertAction(title: "CAD:  \(stringer1(myIn: round.cadences.last!))  RPM", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let a4 = UIAlertAction(title: "GEO:  \(stringer1(myIn: round.geoSpeeds.last!))  MPH", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let percentofmax = stringer2(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
        let cancelAction = UIAlertAction(title: "SCORE:  \(percentofmax) %MAX HR", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(a1)
        optionMenu.addAction(a2)
        optionMenu.addAction(a3)
        optionMenu.addAction(a4)
        optionMenu.addAction(cancelAction)
        
        
        optionMenu.presentInOwnWindow(animated: true, completion: {
            print("completed")
            let when = DispatchTime.now() + 10
            DispatchQueue.main.asyncAfter(deadline: when){
                optionMenu.dismiss(animated: true, completion: nil)
            }
        })
        
    }
    
    
    func newRound(xx: Int) -> Bool {  //every 300 sec
        
        print("Round Complete, New Round Starting, time:  \(xx)")
        
        round.speeds.append(round.speed)
        round.cadences.append(round.cadence)
        round.geoSpeeds.append(round.geoSpeed)
        round.geoDistances.append(geo.total_distance)
        round.heartrates.append(round.hr)
        inRoundHR = 0
        
        roundStartTime = NSDate()
        roundWheelRevs_atStart = totalWheelRevs
        roundCrankRevs_atStart = totalCrankRevs
        roundGeoDistance = geo.total_distance
        
        
        newRoundActionSheet()
        return true
    }
    
    var veloH: Double = 0;
    
    
    
    
    func roundUpdate_each_second(xx: Int) -> Bool {
        //print("roundUpdate_each_second, xx:  \(xx)")
        
        let x = NSDate()
        let y = x.timeIntervalSince(roundStartTime! as Date!)
        let z = Int(y)
        

        inRoundGeoDist = geo.total_distance - roundGeoDistance
        if inRoundGeoDist > 0 {
            inRoundGeoSpeed = Double(inRoundGeoDist / Double((Double(z) / 60.0 / 60.0)))
        } else {
            inRoundGeoSpeed = 0
        }
        
        round.geoSpeed = inRoundGeoSpeed
        round.geoPace = calcMinPerMile(mph: round.geoSpeed)
        inRoundHR += Double(rt.rt_hr)
        
        var avgInRoundHR = inRoundHR / Double(z)
        if avgInRoundHR.isNaN == true || avgInRoundHR.isInfinite == true {
            avgInRoundHR = 0
        }
        round.hr = avgInRoundHR
        
        let a = totalWheelRevs - roundWheelRevs_atStart
        let b = Double(Double(wheelCircumference) / Double(1000)) * 0.000621371
        let c = Double(z) / Double(60) / Double(60)
        //round.inRoundTimer = z
        
        inRoundSpeed = Double(a) * Double(b) / Double(c)
        round.speed = inRoundSpeed
        
        let d = Double(totalCrankRevs - roundCrankRevs_atStart)
        inRoundCadence = (d / y) * 60.0
        round.cadence = inRoundCadence
 
        
        update_Interval_Values()
        if z % 45 == 0
        {
            let h = rt.rt_hr
            if (h == veloH) {rt.rt_hr = 0}
            veloH = h
        }
        return true
    }
    
    var IntRoundChecker = 0
    @objc func newRoundChecker() {
        IntRoundChecker += 1
        let x = NSDate()
        let y = x.timeIntervalSince(startTime! as Date!)
        let z = Double(y)
        if Int(z) > 1 {
            if Int(z) % round.secondsPerRound == 0 || IntRoundChecker >= (round.secondsPerRound) {
                let nr = newRound(xx: Int(z))
                print("new round processing complete:  \(nr)")
                IntRoundChecker = 0
                NotificationCenter.default.post(name: Notification.Name("newRound"), object: nil)
            }
        }

        
    }
    
    @objc func UpdateTimeDisplay() {  //each second
        let x = NSDate()
        let y = x.timeIntervalSince(startTime! as Date!)
        let z = Double(y)  //time in seconds
        
        rt.string_elapsed_time = createTimeString(seconds: Int(z))
        rt.int_elapsed_time = Int(z)  //int for seconds
        
        let ru = roundUpdate_each_second(xx: rt.int_elapsed_time)
        if ru == false {print(ru)}
        
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
        
    }
    
    @IBAction func act_Btn4(_ sender: UIButton) {
        //let mySavedPeripherals = defaults.stringArray(forKey: "Saved_Peripherals") ?? ["None"]
        //print(mySavedPeripherals)
    }
    
    @IBAction func act_Btn5(_ sender: UIButton) {
        disconnectAllPeripherals()
        print("disconnect All")
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
            rt.rt_score = ((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100))
            out_Top1.setTitle(String(bpmValue), for: .normal)
            NotificationCenter.default.post(name: Notification.Name("heartrate"), object: nil)
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
                out_Top2.setTitle(String(value[1]), for: .normal)
                processWheelData(withData: data)
                if flag & CRANK_REVOLUTION_FLAG == 2 {
                    out_Top3.setTitle(String(value[7]), for: .normal)
                    //print("CAD value[7]");print(value[7])
                    processCrankData(withData: data, andCrankRevolutionIndex: 7)
                }
            } else {
                if flag & CRANK_REVOLUTION_FLAG == 2 {
                    out_Top3.setTitle(String(value[1]), for: .normal)
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
    
    func disconnectAllPeripherals() {
        dump(arrPeripheral)
        for p in arrPeripheral {
            // verify we have a peripheral
            
            // check to see if the peripheral is connected
            if p?.state != .connected {
                print("Peripheral exists but is not connected.")
                return
            }
            guard let services = p?.services else {
                print("Cancel Peripheral Connection")
                centralManager.cancelPeripheralConnection(p!)  //no services
                return
            }
            for service in services {
                // iterate through characteristics
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        // find the Transfer Characteristic we defined in our Device struct
                        if characteristic.uuid == CBUUID.init(string: CSC_Char) {
                            p?.setNotifyValue(false, for: characteristic)
                            print("set Notify Value to False for:  \(String(describing: p?.name))")
                            return
                        }
                        if characteristic.uuid == CBUUID.init(string: HR_Char) {
                            p?.setNotifyValue(false, for: characteristic)
                            print("set Notify Value to False for:  \(String(describing: p?.name))")
                            return
                        }
                    }
                }
            }
            // disconnect from the peripheral
            centralManager.cancelPeripheralConnection(p!)
        }
        arr_connected_peripherals = []
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("Did Disconnect Peripheral")
        
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
    var roundMonitorTimer = Timer()

    
    @objc func update_Interval_Values() {
        
        interval.heartrates.append(rt.rt_hr)
        interval.distances.append(rt.total_distance)
        interval.cadences.append(rt.rt_cadence)
        interval.geoDistances.append(geo.total_distance)
        
        interval.hr = (interval.heartrates.reduce(0, +)) / Double(interval.secondsInInterval)
        interval.cadence = (interval.cadences.reduce(0, +)) / Double(interval.secondsInInterval)
        interval.speed = (interval.distances.last! - interval.distances.first!) * (2 * 60)  //30 sec as an hour
        interval.geoSpeed = (interval.geoDistances.last! - interval.geoDistances.first!) * (2 * 60)  //30 sec as an hour

        if interval.heartrates.count == 29 {
            interval.heartrates.removeFirst()
            interval.cadences.removeFirst()
            interval.distances.removeFirst();
            interval.geoDistances.removeFirst()
        }
        
    }
    
    
    var firstLoad = 0
    @IBOutlet var ViewStartup: UIView!
    @IBAction func action_CloseStartupView(_ sender: UIButton) {
        firstLoad = 1
        ViewStartup.removeFromSuperview()
        self.tabBarController?.selectedIndex = 0;
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.BLTE_TableViewOutlet.addSubview(refreshControl)
        
        if rt.int_elapsed_time == 0 {
            startTime = NSDate()
            roundStartTime = startTime
            mainTimer = Timer()
            mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimeDisplay), userInfo: nil, repeats: true)
            print("Start Main Timer:  \(String(describing: startTime))")
            
            
            roundMonitorTimer = Timer()
            roundMonitorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(newRoundChecker), userInfo: nil, repeats: true)
        }
        
        
        if (firstLoad == 0) {
            firstLoad = 1
            ViewStartup.center = view.center
            view.addSubview(ViewStartup)
            
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.ViewStartup.removeFromSuperview()
                self.tabBarController?.selectedIndex = 0;
            }
            
            //            ViewStartup.removeFromSuperview()
            //            self.tabBarController?.selectedIndex = 0;
            
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

