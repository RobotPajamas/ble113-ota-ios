//
//  BluegigaPeripheral.swift
//  ble113-ota
//
//  Created by Suresh Joshi on 2016-06-13.
//  Copyright © 2016 Robot Pajamas. All rights reserved.
//

import LGBluetooth

class BluegigaPeripheral: BaseBluetoothPeripheral {

    private static let packetSize = 16

    private var totalNumberOfPackets: Int = 0
    private var currentPacket: Int = 0
    private var fileData: NSData = NSData()

    enum BluegigaServices {
        static let ota: String = "1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0";
    }

    enum BluegigaCharacteristics {
//        static let control: String = "f7bf3564-fb6d-4e53-88a4-5e37e0326063";
//        static let dataNoAck: String = "984227f3-34fc-4045-a5d0-2c581f81a153";
        static let controlNoAck: String = "01737572-6573-686a-6f73-68692e636f6d";
        static let data: String = "00737572-6573-686a-6f73-68692e636f6d";
    }

    override init(fromPeripheral peripheral: LGPeripheral) {
        super.init(fromPeripheral: peripheral)
    }


    func updateFirmware(fileData1: NSData, callback: Void -> Void) {
        fileData = fileData1
        totalNumberOfPackets = fileData.length / BluegigaPeripheral.packetSize
        currentPacket = 0

        uploadNextPacket(callback)
    }

    private func uploadNextPacket(completion: Void -> Void) {
        if self.currentPacket == self.totalNumberOfPackets {
            // Send reset command
            var resetCommand: UInt8 = 3
            let resetData = NSData(bytes: &resetCommand, length: 1)
            LGUtils.writeData(resetData, charactUUID: BluegigaCharacteristics.controlNoAck, serviceUUID: BluegigaServices.ota, peripheral: self.peripheral, completion: nil)
            completion()
        } else {
            // Send next packet
            print(self.currentPacket)
            let nextPacket = self.fileData.subdataWithRange(NSRange(location: self.currentPacket * BluegigaPeripheral.packetSize, length: BluegigaPeripheral.packetSize))
            self.currentPacket += 1

            LGUtils.writeData(nextPacket, charactUUID: BluegigaCharacteristics.data, serviceUUID: BluegigaServices.ota, peripheral: self.peripheral) {
                error in
                self.uploadNextPacket(completion)
            }
        }
    }
}
