//
//  FirmwareUpdateViewController.swift
//  ble113-ota
//
//  Created by Suresh Joshi on 2016-06-13.
//  Copyright © 2016 Robot Pajamas. All rights reserved.
//

import UIKit

class FirmwareUpdateViewController: UIViewController {

    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var updateButton010: UIButton!
    @IBOutlet weak var updateButton011: UIButton!

    @IBAction func updateToOldFirmare(sender: UIButton) {
        if let firmwarePath = NSBundle.mainBundle().pathForResource("0.1.0", ofType: ".ota", inDirectory: ".") {
            let fileData = NSData(contentsOfFile: firmwarePath)
            self.peripheral?.updateFirmware(fileData!) {
                print("Update to 0.1.0 Completed!")
            }
        }
    }

    @IBAction func updateToNewFirmware(sender: UIButton) {
        if let firmwarePath = NSBundle.mainBundle().pathForResource("0.1.1", ofType: ".ota", inDirectory: ".") {
            let fileData = NSData(contentsOfFile: firmwarePath)
            self.peripheral?.updateFirmware(fileData!) {
                print("Update to 0.1.1 Completed!")
            }
        }
    }

    // Just sticking this here, so I can set it from the scan viewcontroller
    var peripheral: BluegigaPeripheral?

    override func viewDidLoad() {
        updateButton010.hidden = true
        updateButton011.hidden = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Note: Not a lot of safety around connection checks
        // This is a proof of concept, not a rock-solid update controller
        if peripheral?.isConnected() == true {
            updateButton010.hidden = false
            updateButton011.hidden = false
        } else {
            updateButton010.hidden = true
            updateButton011.hidden = true

            peripheral?.connect(withTimeout: 5) {
                error in
                if error == nil {
                    self.peripheral?.readDeviceInformation() {
                        self.firmwareVersionLabel.text = self.peripheral?.firmwareRevision
                        self.updateButton010.hidden = false
                        self.updateButton011.hidden = false
                    }
                }
            }
        }
    }

}
