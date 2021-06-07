//
//  BleFunction.swift
//  MyFrame
//
//  Created by 임시 사용자 (DJ) on 2021/06/03.
//

import CoreBluetooth

public class BleVO{
    public static var centralManager: CBCentralManager!
    public static var characteristic: CBCharacteristic!
    public static var peripheralObj: CBPeripheral!
    public static var soundFuncState: Bool = false
    
    public static func setBleObj(peripheralObj: CBPeripheral,
                      centralManager: CBCentralManager, characteristic: CBCharacteristic?){
        self.peripheralObj = peripheralObj
        self.centralManager = centralManager
        if !(characteristic == nil) {
            self.characteristic = characteristic
        }
    }
}
