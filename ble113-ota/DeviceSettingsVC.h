//
//  DeviceListTVC.h
//  ble113-ota
//
//  Created by Suresh Joshi on 15-03-07.
//  Copyright (c) 2015 Robot Pajamas. All rights reserved.
//


#import <UIKit/UIKit.h>

@class SampleDevice;


@interface DeviceSettingsVC : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate, UIAlertViewDelegate>

/*
 * Expose a Sample Device to be set externally for this class to operate on
 */
@property(nonatomic, retain) SampleDevice *device;

@end
