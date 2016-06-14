//
//  ViewController.swift
//  ble113-ota
//
//  Created by Suresh Joshi on 2016-06-13.
//  Copyright © 2016 Robot Pajamas. All rights reserved.
//

import UIKit
import LGBluetooth

class DeviceListViewController: UITableViewController {

    private static let cellIdentifier = "cellIdentifier"
    
    var scannedPeripherals = [BluegigaPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        setupUi()
        initCoreBluetooth()
    }
    
    func setupUi() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(DeviceListViewController.scanForDevices), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    // This is a nothing function, strictly here to initialize CoreBluetooth
    func initCoreBluetooth() {
        let callback: LGCentralManagerDiscoverPeripheralsCallback = {
            peripherals in
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(DeviceListViewController.scanForDevices), userInfo: nil, repeats: false)
        }
        LGCentralManager.sharedInstance().scanForPeripheralsByInterval(1, completion: callback)
    }

    // The bulk of the advertising data is done here
    func scanForDevices() {
        let callback: LGCentralManagerDiscoverPeripheralsCallback = {
            peripherals in
            self.refreshControl!.endRefreshing()
            for peripheral in peripherals {
                let p = peripheral as! LGPeripheral
                if p.name?.lowercaseString.containsString("robot pajamas") == true {
                    let bluegigaPeripheral = BluegigaPeripheral(fromPeripheral: p)
                    self.scannedPeripherals.append(bluegigaPeripheral)
                }
            }
            self.tableView.reloadData()
        }
        
        print("Start scanning...")
        scannedPeripherals.removeAll()
        LGCentralManager.sharedInstance().scanForPeripheralsByInterval(5, completion: callback)
    }
    
    // MARK: UITableViewDataSource methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedPeripherals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DeviceListViewController.cellIdentifier)
        
        let peripheral = scannedPeripherals[indexPath.row]
        cell!.textLabel?.text = peripheral.name
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToFirmwareUpdate" {
            let path = self.tableView.indexPathForSelectedRow!
            let peripheral = scannedPeripherals[path.row]
            let destination = segue.destinationViewController as! FirmwareUpdateViewController
            destination.peripheral = peripheral
        }
    }


}

