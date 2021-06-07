//
//  BleScanController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/05/30.
//

import UIKit
import CoreBluetooth
import MyFrame

class BleScanController: UIViewController {
    @IBOutlet weak var btnOfScan: UIButton!
    @IBOutlet weak var tblOfList: UITableView!
    
    var peripherals:[CBPeripheral] = []
    var peripheralObj: CBPeripheral!
    var centralManager: CBCentralManager!
    var characteristic: CBCharacteristic!
    
    let deviceCharCBUUID = CBUUID(string: "FFE1")
    let data = NSMutableData()
    
    /*스캔 함수*/
    @IBAction func btnScanClick( sender: Any) {
        if(centralManager.isScanning) {
            centralManager.stopScan()
        }
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /*NavBar 컬러 변경*/
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    /*초기화 함수*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblOfList.delegate = self
        tblOfList.dataSource = self
        
        self.tblOfList.tableFooterView = UIView()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

/*테이블 뷰 관련 확장 BleScanController*/
extension BleScanController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblOfList.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular) 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        
        peripheralObj = peripheral
        centralManager.connect(peripheralObj)
    }
}

/*블루투스 관련 확장 BleScanController*/
extension BleScanController : CBPeripheralDelegate, CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !(peripheral.name ?? "").isEmpty {
            var check:Bool = false
            for p in peripherals {
                if(p.name == peripheral.name) {
                    check = true
                }
            }
            
            if(!check) {
                self.peripherals.append(peripheral)
                
                DispatchQueue.main.async(execute: {
                    self.tblOfList.reloadData()
                    self.tblOfList.contentOffset = .zero
                })
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager?.stopScan()
        
        //연결 장치 설정 및 서비스 탐색
        peripheralObj.delegate = self
        peripheralObj.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([deviceCharCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chars = service.characteristics else { return }
        
        for char in chars {
            characteristic = char
            if char.uuid.isEqual(deviceCharCBUUID) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
        
        connectionObjSet()
        
        let content = "Connected to  \(peripheralObj.name!)\nScanning stopped"
        alertConnection(title: "연결 성공", content: content)
    }
    
    /*공통으로 사용할 객체에 BLE객체 설정*/
    func connectionObjSet(){
        BleVO.setBleObj(peripheralObj: self.peripheralObj, centralManager: self.centralManager, characteristic: self.characteristic)
    }
    
    /*알림 팝업 호출 함수*/
    func alertConnection(title: String, content: String){
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in self.navigationController?.popViewController(animated: true)
            
        }
        alert.addAction(okAction)
        
        present(alert, animated: false, completion: nil)
    }
}
