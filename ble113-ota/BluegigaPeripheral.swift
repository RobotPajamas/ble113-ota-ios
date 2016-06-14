//
//  BluegigaPeripheral.swift
//  ble113-ota
//
//  Created by Suresh Joshi on 2016-06-13.
//  Copyright © 2016 Robot Pajamas. All rights reserved.
//

import LGBluetooth

class BluegigaPeripheral: BaseBluetoothPeripheral {

    enum BluegigaServices {
        static let ota: String = "1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0";
    }
    
    enum BluegigaCharacteristics {
//        static let control: String = "f7bf3564-fb6d-4e53-88a4-5e37e0326063";
//        static let dataNoAck: String = "984227f3-34fc-4045-a5d0-2c581f81a153";
        
        static let controlNoAck: String = "01737572-6573-686a-6f73-68692e636f6d";
        static let data: String = "00737572-6573-686a-6f73-68692e636f6d";
    }
    
    

    
}
