//
//  DeviceController.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/05/31.
//

import UIKit
import CoreBluetooth
import MyFrame

class DeviceController: UIViewController {
    @IBOutlet weak var btnBeamPower: UIButton!
    @IBOutlet weak var btnBeamInput: UIButton!
    @IBOutlet weak var btnBeamPrePlay: UIButton!
    @IBOutlet weak var btnBeamPlay: UIButton!
    @IBOutlet weak var btnBeamNextPlay: UIButton!
    @IBOutlet weak var btnBeamUp: UIButton!
    @IBOutlet weak var btnBeamLeft: UIButton!
    @IBOutlet weak var btnBeamRight: UIButton!
    @IBOutlet weak var btnBeamDown: UIButton!
    @IBOutlet weak var btnBeamOk: UIButton!
    @IBOutlet weak var btnBeamMenu: UIButton!
    @IBOutlet weak var btnBeamPre: UIButton!
    @IBOutlet weak var btnBeamBackMove: UIButton!
    @IBOutlet weak var btnBeamForwardMove: UIButton!
    @IBOutlet weak var btnBeamVolumeDown: UIButton!
    @IBOutlet weak var btnBeamVolumeMute: UIButton!
    @IBOutlet weak var btnBeamVolumeUp: UIButton!
    
    let data = NSMutableData()
    
    /*버튼 터치 시, 해당 BLE 문자 전송하는 함수*/
    @IBAction func buttonTapped(btn : UIButton){
        guard let strDataParam = btn.restorationIdentifier else { return }
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

