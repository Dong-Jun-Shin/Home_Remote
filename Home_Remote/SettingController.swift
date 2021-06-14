//
//  SettingController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/05/31.
//

import UIKit
import CoreBluetooth
import MyFrame

class SettingController: UIViewController {
    @IBOutlet weak var cdsFuncChk: UISwitch!
    @IBOutlet weak var airconChk: UISwitch!
    @IBOutlet weak var fanChk: UISwitch!
    @IBOutlet weak var autoFuncChk: UISwitch!
    @IBOutlet weak var autoAirconChk: UISwitch!
    @IBOutlet weak var autoFanChk: UISwitch!
    @IBOutlet weak var txtOfOnTime: UITextField!
    @IBOutlet weak var txtOfOffTime: UITextField!
    
    let deviceCharCBUUID = CBUUID(string: "FFE1")
    let data = NSMutableData()
    
    /*Switch 전체 기능 값 변경 시, Switch 상태 변경 함수*/
    @IBAction func changeCdsFunc(_ sender: Any) {
        if cdsFuncChk.isOn {
            airconChk.isEnabled = true
            fanChk.isEnabled = true
        }else{
            airconChk.isEnabled = false
            fanChk.isEnabled = false
        }
        
        if autoFuncChk.isOn {
            autoAirconChk.isEnabled = true
            autoFanChk.isEnabled = true
        }else{
            autoAirconChk.isEnabled = false
            autoFanChk.isEnabled = false
        }
    }
    
    /*Switch 세부 기능 값 변경 시, BLE 문자 전송 함수*/
    @IBAction func changeFunc(switchObj : UISwitch) {
        guard let strDataParam = switchObj.restorationIdentifier else { return }
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            sendData(strData: strDataParam)
        }
    }
    
    /*설정 시간 입력 시, BLE 문자 전송 함수*/
    @IBAction func sendSetTime(txtField: UITextField) {
        guard let strDataParam = txtField.text else { return }
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            let setData = txtField.restorationIdentifier! + "," + strDataParam
            sendData(strData: setData)
        }
    }
    
    /*화면 터치해서 키보드 내리는 함수*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*NavBar 컬러 변경*/
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    /*NavBar hide 함수*/
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //자동기능 관련 값 설정
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            BleVO.peripheralObj.delegate = self
            sendData(strData: "z")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /* BLE 문자 데이터 생성 및 호출 함수*/
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

extension SettingController: CBPeripheralDelegate,  CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
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
            // 수신한 문자가 담긴 stringFromData 사용
            switchInitSet(nsStr: stringFromData)
        }
    }
    
    /*받은 문자열을 이용해서 Switch 상태 설정하는 함수*/
    func switchInitSet(nsStr: NSString){
        let str = "\(nsStr)"
        let strArr = str.split(separator: "/")
        
        if strArr.count == 3 {
            let cdsFuncArr = strArr[0].split(separator: ",")
            let autoFuncArr = strArr[1].split(separator: ",")
            let deviceFuncArr = strArr[2].split(separator: ",")
        
            if cdsFuncArr.count == 3 {
                let cdsFuncSwitch = cdsFuncArr[0]
                let airconSwitch = cdsFuncArr[1]
                let fanSwitch = cdsFuncArr[2]
                
                cdsFuncChk.isOn = stringToBool(val: cdsFuncSwitch)
                airconChk.isOn = stringToBool(val: airconSwitch)
                fanChk.isOn = stringToBool(val: fanSwitch)
            }
            
            if autoFuncArr.count == 3 {
                let autoFuncSwitch = autoFuncArr[0]
                let autoAirconSwitch = autoFuncArr[1]
                let autoFanSwitch = autoFuncArr[2]
                
                autoFuncChk.isOn = stringToBool(val: autoFuncSwitch)
                autoAirconChk.isOn = stringToBool(val: autoAirconSwitch)
                autoFanChk.isOn = stringToBool(val: autoFanSwitch)
            }
            
            if deviceFuncArr.count == 2 {
                let sountFuncSwitch = deviceFuncArr[0]
                let windFuncSwitch = deviceFuncArr[1]
                
                BleVO.soundFuncState = stringToBool(val: sountFuncSwitch)
                BleVO.windFuncState = stringToBool(val: windFuncSwitch)
            }
        }
    }
    
    /*Int를 Bool로 변환하는 함수*/
    func stringToBool(val: String.SubSequence) -> Bool{
        if val == "0" {
            return false
        }else{
            return true
        }
    }
}

