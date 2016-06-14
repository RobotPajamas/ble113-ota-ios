//
//  BaseBluetoothPeripheral.swift
//  ble113-ota
//
//  Created by Suresh Joshi on 2016-06-13.
//  Copyright © 2016 Robot Pajamas. All rights reserved.
//

import LGBluetooth

class BaseBluetoothPeripheral {
    
    // Standard BLE services
    enum StandardServices {
        static let deviceInformation: String = "180A";
    }
    
    enum StandardCharacteristics {
        static let manufacturerModel: String = "2A24";
        static let serialNumber: String = "2A25";
        static let firmwareVersion: String = "2A26";
        static let hardwareVersion: String = "2A27";
        static let softwareVersion: String = "2A28";
        static let manufacturerName: String = "2A29";
    }
    
    var peripheral: LGPeripheral!
    
    var name: String?
    var rssi: Int?
    
    // Properties for the standard services
    var manufacturerModel: String?
    var serialNumber: String?
    var firmwareRevision: String?
    var hardwareRevision: String?
    var softwareRevision: String?
    var manufacturerName: String?
    
    /**
     * Constructor
     * @param peripheral LGPeripheral instance representing this device
     */
    init(fromPeripheral peripheral: LGPeripheral) {
        self.peripheral = peripheral
        self.name = self.peripheral.name
        self.rssi = self.peripheral.RSSI
    }
    
    /**
     * Determines if this peripheral is currently connected or not
     */
    func isConnected() -> Bool {
        return peripheral.cbPeripheral.state == .Connected
    }
    
    /**
     * Opens connection with a timeout to this device
     * @param timeout Timeout after which, connection will be closed (if it was in stage isConnecting)
     * @param callback Will be called after connection success/failure
     */
    func connect(withTimeout timeout: UInt, callback: (NSError!) -> Void) {
        peripheral.connectWithTimeout(timeout, completion: callback)
    }
    
    /**
     * Disconnects from device
     * @param callback Will be called after disconnection success/failure
     */
    func disconnect(callback: (NSError?) -> Void) {
        peripheral.disconnectWithCompletion(callback)
    }
    
    /**
     * Reads all standard BLE information from device (manufacturer, firmware, hardware, serial number, etc...)
     * @param callback Will be called when all information is ready (or failed to gather data)
     */
    func readDeviceInformation(callback: () -> Void) {
        // Using RxSwift would be great to clean up this super messy nested block business...
        // self.readSoftwareRevision({ <-- not implemented in firmawre
        self.readManufacturerModel({
            self.readSerialNumber({
                self.readFirmwareRevision({
                    self.readHardwareRevision({
                        self.readManufacturerName(callback)
                    })
                })
            })
        })
    }
    
    /**
     * Read in the manufacturer name
     * @param callback Will be called when the call returns with success or error
     */
    private func readManufacturerName(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.manufacturerName = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.manufacturerName, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
    
    /**
     * Read in the manufacturer model
     * @param callback Will be called when the call returns with success or error
     */
    private func readManufacturerModel(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.manufacturerModel = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.manufacturerModel, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
    
    /**
     * Read in the hardware revision
     * @param callback Will be called when the call returns with success or error
     */
    private func readHardwareRevision(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.hardwareRevision = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.hardwareVersion, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
    
    /**
     * Read in the firmware version
     * @param callback Will be called when the call returns with success or error
     */
    private func readFirmwareRevision(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.firmwareRevision = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.firmwareVersion, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
    
    /**
     * Read in the software version
     * @param callback Will be called when the call returns with success or error
     */
    private func readSoftwareRevision(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.softwareRevision = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.softwareVersion, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
    
    /**
     * Read in the serial number
     * @param callback Will be called when the call returns with success or error
     */
    private func readSerialNumber(callback: (() -> ())?) {
        let cb: LGCharacteristicReadCallback = {
            data, error in
            self.serialNumber = String(data: data, encoding: NSUTF8StringEncoding)
            callback?()
        }
        
        LGUtils.readDataFromCharactUUID(StandardCharacteristics.serialNumber, serviceUUID: StandardServices.deviceInformation, peripheral: peripheral, completion: cb)
    }
}
