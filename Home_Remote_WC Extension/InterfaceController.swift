//
//  InterfaceController.swift
//  Home_Remote_WC Extension
//
//  Created by 임시 사용자 (DJ) on 2021/06/17.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var blePower: WKInterfaceButton!
    @IBOutlet weak var lightPower: WKInterfaceButton!
    @IBOutlet weak var fanPower: WKInterfaceButton!
    @IBOutlet weak var airconPower: WKInterfaceButton!
    
    @IBOutlet weak var lblOfState: WKInterfaceLabel!
    
    let session = WCSession.default
    
    /*BTN Tapping시, BLE 연결 요청*/
    @IBAction func bleConnectToiPhone() {
        sendToPhoneData(str: "ble")
        lblOfState.setText("BLE")
    }
    
    /*BTN Tapping시, 전등 제어 요청*/
    @IBAction func lightPowerToiPhone() {
        sendToPhoneData(str: "light")
        lblOfState.setText("Light")
    }
    
    /*BTN Tapping시, 선풍기 제어 요청*/
    @IBAction func fanPowerToiPhone() {
        sendToPhoneData(str: "fan")
        lblOfState.setText("Fan")
    }
    
    /*BTN Tapping시, 에어컨 제어 요청*/
    @IBAction func airconPowerToiPhone() {
        sendToPhoneData(str: "aircon")
        lblOfState.setText("Aircon")
    }
    
    /*어플 실행 시, 실행*/
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session.delegate = self
        session.activate()
    }
    
    /*화면이 표시될 때, 실행*/
    override func willActivate() {
        super.willActivate()
        sendToPhoneData(str: "init")
        lblOfState.setText("Wait Command...")
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

/*Watch Session 관련 확장 MainController*/
extension InterfaceController: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    /*(iPhone > Watch) 데이터 수신*/
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received data: \(message)")
        
        //BLE 연결 정보 받기
        DispatchQueue.main.async{
            if let value = message["iPhone"] as? String{
                if value == "connect" {
                    self.blePower.setBackgroundImageNamed("connect")
                }else if value == "unconnect" {
                    self.blePower.setBackgroundImageNamed("discon")
                }else {
                    self.blePower.setBackgroundImageNamed("discon")
                    print("irregularity value")
                }
            }
        }
    }
    
    /*(Watch > iPhone) 데이터 송신*/
    func sendToPhoneData(str: String){
        let data: [String: Any] = ["watch": str as Any]
        session.sendMessage(data, replyHandler: {(replyDict) in print(replyDict)}, errorHandler: {(error) in print(error)
        })
    }
}
