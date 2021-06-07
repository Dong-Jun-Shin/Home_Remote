//
//  HomeCtrController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/05/31.
//

import UIKit
import CoreBluetooth
import MyFrame

class HomeCtrController: UIViewController {
    @IBOutlet weak var soundFuncChk: UISwitch!
    @IBOutlet weak var airconOn: UIButton!
    @IBOutlet weak var airconOff: UIButton!
    @IBOutlet weak var blindUp: UIButton!
    @IBOutlet weak var blindDown: UIButton!
    @IBOutlet weak var fanPower: UIButton!
    @IBOutlet weak var fanForce: UIButton!
    @IBOutlet weak var fanReservation: UIButton!
    @IBOutlet weak var fanRotate: UIButton!
    @IBOutlet weak var fanMode: UIButton!
    
    let data = NSMutableData()
    
    /*버튼 터치 시, 해당 BLE 문자 전송하는 함수*/
    @IBAction func buttonTapped(btn : UIButton){
        guard let strDataParam = btn.restorationIdentifier else { return }
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            sendData(strData: strDataParam)
        }
    }
    
    /*Switch 세부 기능 값 변경 시, BLE 문자 전송 함수*/
    @IBAction func changeFunc(switchObj : UISwitch) {
        guard let strDataParam = switchObj.restorationIdentifier else { return }
        if !(BleVO.centralManager == nil || BleVO.characteristic == nil || BleVO.peripheralObj == nil) {
            sendData(strData: strDataParam)
        }
    }
    
    /*NavBar 컬러 변경*/
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /*NavBar hide 함수*/
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        soundFuncChk.isOn = BleVO.soundFuncState
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

