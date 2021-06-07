//
//  MainController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/05/31.
//

import UIKit
import CoreBluetooth
import Charts
import MyFrame

class MainController: UIViewController {
    @IBOutlet weak var lblOfTemp: UILabel!
    @IBOutlet weak var lblOfHumi: UILabel!
    @IBOutlet weak var lblOfCds: UILabel!
    @IBOutlet weak var lblOfRecommend: UILabel!
    @IBOutlet weak var btnOfBLE: UIButton!
    @IBOutlet weak var btnOfDiscon: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lblOfBTState: UILabel!
    
    let deviceCharCBUUID = CBUUID(string: "FFE1")
    let data = NSMutableData()
    var strData = ""
    
    /*NavBar 컬러 변경*/
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 차트 설정
        // 데이터 없을 시, 설정
        lineChartView.noDataText = "온도 데이터가 없습니다."
        lineChartView.noDataFont = .systemFont(ofSize: 20)
        lineChartView.noDataTextColor = .systemGray
        
        barChartView.noDataText = "습도 데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .systemGray
    }
    
    /*NavBar hide 함수*/
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //연결 아이콘 변경
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            // 연결 상태 아이콘 변경
            changeConImage(iconName: "bt_con", message: "홈 IoT 연결 상태 (Connect)")
            
            // 온습도, 조도 값 설정
            BleVO.peripheralObj.delegate = self
            strData = "Z"
            sendData(strData: strData)
            
            // 통계 설정
//            strData = "?"
//            sendData(strData: strData)
        }
    }
    
    /*온습도, 조도 값 설정하는 함수*/
    func tempInitSet(nsStr: NSString){
        let str = "\(nsStr)"
        let strArr = str.split(separator: "/")

        //온습도, 조도 설정
        if !(strArr.isEmpty) || strArr.count==3 {
            let str = "\(nsStr)"
            let strArr = str.split(separator: ",")
            
            let humi = strArr[0]
            let temp = strArr[1]
            let cds = strArr[2]
        
            let humiDouble = Double(humi)
            var humiStr = ""
            let humiDiff = Int(humiDouble!) - 55
            
            if humiDiff < 0 {
                humiStr = "\(abs(humiDiff))% 높이시길 권장드립니다."
            }else if humiDiff > 0 {
                humiStr = "\(abs(humiDiff))% 낮추시길 권장드립니다."
            }else if humiDiff == 0 {
                humiStr = " 조절할 필요 없습니다."
            }
            
            lblOfHumi.text = humi + " %"
            lblOfTemp.text = temp + "℃"
            lblOfCds.text = cds + " lux"
            lblOfRecommend.text = "습도를 \(humiStr)"
        }else{
            lblOfHumi.text = "- %"
            lblOfTemp.text = "-℃"
            lblOfCds.text = "- lux"
            lblOfRecommend.text = "비교할 데이터가 없습니다."
        }
    }
    
    /*통계 값 설정하는 함수*/
    func tempArrInitSet(nsStr: NSString){
        let str = "\(nsStr)"
        let strArr = str.split(separator: "/")

        // 통계 설정
        if !(strArr.isEmpty) || strArr.count==2 {
//            let tempArr = strArr[0].split(separator: ",")
//            let humiArr = strArr[1].split(separator: ",")

            let tempArr = [20.0, 23.0, 17.0, 10.0, 28.0, 30.0, 34.0, 38.0, 37.0, 40.0, 23.0, 17.0]
            let humiArr = [48.0, 65.0, 70.0, 40.0, 50.0, 40.0, 62.0, 58.0, 60.0, 79.0, 80.0, 76.0]
            
            let hours = ["12시간 전","11시간 전","10시간 전","9시간 전","8시간 전","7시간 전","6시간 전","5시간 전","4시간 전","3시간 전","2시간 전","1시간 전"]
            
            ChartFunction.setLineChart(lineChartView: lineChartView, dataPoints: hours, values: tempArr)
            ChartFunction.setBarChart(barChartView: barChartView, dataPoints: hours, values: humiArr)
        }else{
            lineChartView.data = nil
            barChartView.data = nil
        }
    }
    
    /*알람 띄우기*/
    func alertConnection(title: String, content: String){
        //
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alert.addAction(okAction)
        
        present(alert, animated: false, completion: nil)
    }
    
    /*connect 아이콘 변경*/
    func changeConImage(iconName: String, message: String){
        self.btnOfBLE.setImage(UIImage(named: iconName), for: UIControl.State.normal)
        self.lblOfBTState.text = message
    }
    
    /*BLE 문자 데이터 생성 및 호출 함수*/
    func sendData(strData: String) {
        let data = String(format: "%@", strData)
        guard let valueString = data.data(using: String.Encoding.utf8) else { return }
        writeValueToChar(withCharacteristic: BleVO.characteristic, withValue: valueString)
    }
    
    /*BLE 문자 전송 함수*/
    func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data){
        if BleVO.characteristic.properties.contains(.writeWithoutResponse) && BleVO.peripheralObj != nil {
            BleVO.peripheralObj.writeValue(value, for: BleVO.characteristic, type: .withoutResponse)
        }
    }
}

/*블루투스 관련 확장 BleScanController*/
extension MainController: CBPeripheralDelegate, CBCentralManagerDelegate{
    /*버튼 클릭 시, BLE 연결 뷰 이동*/
    @IBAction func btnBleClick(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "BleScanController") as? BleScanController else { return }
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /*버튼 클릭 시, 연결된 BLE 객체 연결 해제*/
    @IBAction func bteDisconClick(_ sender: Any) {
        var content = ""
        
        if BleVO.peripheralObj != nil {
            BleVO.centralManager.cancelPeripheralConnection(BleVO.peripheralObj)
            BleVO.peripheralObj = nil
            content = "Disconnection"
        }else{
            content = "Not Connection"
        }
        
        alertConnection(title: "연결 해제", content: content)
        changeConImage(iconName: "bt_uncon", message: "홈 IoT 연결 상태 (Disconnect)")
        tempInitSet(nsStr: "")
    }
    
    /*특정 BLE장치 탐색 시작부*/
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [deviceCharCBUUID], options: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 20, execute: {
                if central.isScanning {
                    central.stopScan()
                }
            })
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "PROJECT_BLE" {
            BleVO.centralManager.stopScan()
            BleVO.centralManager.connect(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        BleVO.centralManager = central
        BleVO.peripheralObj = peripheral
        
        peripheral.delegate = self
        peripheral.discoverServices([deviceCharCBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([deviceCharCBUUID], for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for character in service.characteristics! {
            BleVO.characteristic = character
            peripheral.setNotifyValue(true, for: character)
        }
    }
    /*특정 BLE장치 탐색 종료부*/
    
    
    /*BLE 문자 수신 함수*/
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let stringFromData = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) else {
            print("Invalid data")
            return
        }
        
        if stringFromData.isEqual(to: "EOM") {
            peripheral.setNotifyValue(false, for: characteristic)
            
            BleVO.centralManager?.cancelPeripheralConnection(peripheral)
        } else {
            data.append(characteristic.value!)
            
            if strData=="Z" {
                tempInitSet(nsStr: stringFromData)
                
                strData = "?"
                sendData(strData: "Z")
            }else if strData=="?"{
                tempArrInitSet(nsStr: stringFromData)
            }
        }
    }
}
