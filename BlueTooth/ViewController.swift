//
//  ViewController.swift
//  BlueTooth
//
//  Created by allen on 2022/8/25.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {

    var peripherals : [CBPeripheral] = []
    var service : CBService!
    var central : CBCentralManager!
    var services : [Any] = []
    var characteristics : [Any] = []
    var count = 2

    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        central = CBCentralManager(delegate: self, queue: nil)

        myTableView.delegate = self
        myTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reload), userInfo: nil, repeats: true)
        }

    @objc func reload(){
        print(services.count)
            count -= 1
            if count < 0 {
                myTableView.reloadData()
                Timer.initialize()
            }
        }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            print("藍芽開啟")
        case CBManagerState.unauthorized:
            print("沒有藍芽版本")
        case CBManagerState.poweredOff:
            print("藍芽關閉")
        default:
            print("未知狀態")
        }
        central.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print(name)
        }

        for newPeripheral in peripherals {
            if peripheral.name == newPeripheral.name {
                return
            }
        }
        if peripheral.name != nil {
            peripherals.append(peripheral)
        }
        myTableView.reloadData()

    }


    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            print(name)
        }
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        central.stopScan()
    }

    func writeValueForCharacteristic(hex: Data, forCharacteristic characteristic: CBCharacteristic) {
        if peripherals == nil {
            return
        }
        if((characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue) == CBCharacteristicProperties.write.rawValue) {
            
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil) {
            print("尋找services時\(peripheral.name) 發生錯誤\(error?.localizedDescription)")
        }
        services = peripheral.services!
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
            print("service: \(service.uuid.uuidString)")
        }

    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
            print("尋找characteristics時\(peripheral.name) 發生錯誤\(error?.localizedDescription)")
        }
        characteristics = service.characteristics!
        for characteristic in service.characteristics! {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            print(characteristic)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let resultStr = NSString(data: characteristic.value ?? Data(base64Encoded: "")!, encoding: String.Encoding.utf8.rawValue)

        print("characteristic uuid:\(characteristic.uuid.uuidString) properties:\(characteristic.properties)")
    }


    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("RSSI: \(RSSI)")
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")

                cell?.textLabel?.text = peripherals[indexPath.row].name
        cell?.detailTextLabel?.text = "\(peripherals[indexPath.row].readRSSI())"

                return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        services.removeAll()
        characteristics.removeAll()
        central?.connect(peripherals[indexPath.row], options: nil)
    }







}

