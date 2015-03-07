//
// Created by Suresh Joshi on 15-03-07.
// Copyright (c) 2015 Robot Pajamas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGPeripheral.h"


typedef void (^RPDeviceConnectionCallback)(NSError *error);

typedef void (^RPDeviceReadCallback)();

typedef void (^RPDeviceUpdateCallback)();

typedef void (^RPDeviceFirmwareUpdateCallback)(int currentFrame, int totalFrames);

@interface SampleDevice : NSObject


@property(strong, nonatomic, readonly) LGPeripheral *device;

@property(strong, nonatomic, readonly) NSString *deviceName;

@property(strong, nonatomic, readonly) NSString *manufacturerModel;
@property(strong, nonatomic, readonly) NSString *firmwareRevision;
@property(strong, nonatomic, readonly) NSString *hardwareRevision;
@property(strong, nonatomic, readonly) NSString *softwareRevision;
@property(strong, nonatomic, readonly) NSString *manufacturerName;


- (id)initWithDevice:(LGPeripheral *)device;

/**
* Opens connection WITH timeout to this peripheral
* @param aWatchDogInterval timeout after which, connection will be closed (if it was in stage isConnecting)
* @param aCallback Will be called after successful/failure connection
*/
- (void)connectWithTimeout:(NSUInteger)aWatchDogInterval
                completion:(LGPeripheralConnectionCallback)aCallback;

/**
* Disconnects from peripheral peripheral
* @param aCallback Will be called after successful/failure disconnect
*/
- (void)disconnectWithCompletion:(LGPeripheralConnectionCallback)aCallback;

// Read the device information from the sample device.
- (void)readDeviceInformationWithCompletion:(RPDeviceUpdateCallback)aCallback;

- (void)resetDevice;

/**
* Takes passed in NSData (representing firmware to be uploaded) and internally completes the firmware update process.
* When all frames have been uploaded, the device will reset itself.
* @param progressCallback will be called after every successful frame write (with the number of frames remaining and total)
* @param completionCallback will be called at the end of the update process
*/
- (void)updateFirmware:(NSData *)firmwareBytes
              progress:(RPDeviceFirmwareUpdateCallback)progressCallback
            completion:(RPDeviceFirmwareUpdateCallback)completionCallback;


@end