//
// Created by Suresh Joshi on 15-03-07.
// Copyright (c) 2015 Robot Pajamas. All rights reserved.
//

#import "SampleDevice.h"
#import "RPJDataChunker.h"
#import <LGBluetooth/LGUtils.h>


// Standard services
static NSString *const kServiceDeviceInformation = @"180A";
static NSString *const kCharacteristicModel = @"2A24";
static NSString *const kCharacteristicFirmwareVersion = @"2A26";
static NSString *const kCharacteristicHardwareVersion = @"2A27";
static NSString *const kCharacteristicSoftwareVersion = @"2A28";
static NSString *const kCharacteristicManufacturerName = @"2A29";

// OTA services
NSString *const kServiceOTA = @"1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0";
NSString *const kCharacteristicOTAControl = @"f7bf3564-fb6d-4e53-88a4-5e37e0326063";
NSString *const kCharacteristicOTAData = @"984227f3-34fc-4045-a5d0-2c581f81a153";
NSString *const kCharacteristicOTADataWithResponse = @"00737572-6573-686a-6f73-68692e636f6d";
NSString *const kCharacteristicOTAControlNoResponse = @"01737572-6573-686a-6f73-68692e636f6d";

// Device Control
NSString *const kServiceControl = @"e04e83bc-c303-49f4-b3a4-92c72996662c";
NSString *const kCharacteristicReset = @"57a6e8cb-2971-4950-8883-e345290711aa";


@interface SampleDevice ()

@end

@implementation SampleDevice

# pragma mark Public Functions

- (id)initWithDevice:(LGPeripheral *)device {
    if (self = [super init]) {
        _device = device;
        _deviceName = (device.advertisingData)[@"kCBAdvDataLocalName"];
    }
    return self;
}

- (void)connectWithTimeout:(NSUInteger)aWatchDogInterval
                completion:(LGPeripheralConnectionCallback)aCallback
{
    [self.device connectWithTimeout:aWatchDogInterval
                             completion:aCallback];
}

- (void)disconnectWithCompletion:(LGPeripheralConnectionCallback)aCallback
{
    [self.device disconnectWithCompletion:aCallback];
}


- (void)readDeviceInformationWithCompletion:(RPDeviceUpdateCallback)aCallback {
    // TODO: Using ReactiveCocoa would be great to clean up this super messy nested block business...  Not a fan...
    [self readManufacturerNameWithCompletion:^{
        [self readManufacturerModelWithCompletion:^{
            [self readHardwareRevisionWithCompletion:^{
                [self readFirmwareRevisionWithCompletion:^{
                    [self readSoftwareRevisionWithCompletion:aCallback];
                }];
            }];
        }];
    }];
}

- (void)resetDevice
{
    [self sendReset];
}


- (void)updateFirmware:(NSData *)firmwareBytes
              progress:(RPDeviceFirmwareUpdateCallback)progressCallback
            completion:(RPDeviceFirmwareUpdateCallback)completionCallback
{
    // Create a filechunker to split up the incoming file into sendable chunks
    RPJDataChunker *chunker = [[RPJDataChunker alloc] initWithData:firmwareBytes chunkLength:16];

    // Create block for recursive send - need weak reference to avoid retain cycle
    __block __weak LGCharacteristicWriteCallback weakFirmwareCallback;
    LGCharacteristicWriteCallback firmwareCallback;
    weakFirmwareCallback = firmwareCallback = ^(NSError *error){
        if ([chunker hasNext])
        {
            NSData *nextFrame = [chunker next];
            progressCallback([chunker currentChunk], [chunker totalChunks]);
            [self writeFirmwareFrameWithCompletion:nextFrame
                                        completion:weakFirmwareCallback];
        }
        else
        {
            // Reset the chunker, just in case
            [chunker reset];
            [self sendResetToDFU];
            completionCallback([chunker totalChunks], [chunker totalChunks]);
        }
    };

    // Recursively send chunks to wristband and notify callback
    NSData *initialFrame = [chunker next];
    [self writeFirmwareFrameWithCompletion:initialFrame
                                completion:firmwareCallback];
}

# pragma mark Private Functions

- (void)readManufacturerNameWithCompletion:(RPDeviceUpdateCallback)aCallback {
    [LGUtils readDataFromCharactUUID:kCharacteristicManufacturerName
                         serviceUUID:kServiceDeviceInformation
                          peripheral:self.device
                          completion:^(NSData *data, NSError *error) {
                              NSString *manufacturerName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _manufacturerName = manufacturerName;
                              if (aCallback) {
                                  aCallback();
                              }
                          }];
}


- (void)readManufacturerModelWithCompletion:(RPDeviceUpdateCallback)aCallback {
    [LGUtils readDataFromCharactUUID:kCharacteristicModel
                         serviceUUID:kServiceDeviceInformation
                          peripheral:self.device
                          completion:^(NSData *data, NSError *error) {
                              NSString *manufacturerModel = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _manufacturerModel = manufacturerModel;
                              if (aCallback) {
                                  aCallback();
                              }
                          }];
}

- (void)readHardwareRevisionWithCompletion:(RPDeviceUpdateCallback)aCallback {
    [LGUtils readDataFromCharactUUID:kCharacteristicHardwareVersion
                         serviceUUID:kServiceDeviceInformation
                          peripheral:self.device
                          completion:^(NSData *data, NSError *error) {
                              NSString *hardwareRevision = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _hardwareRevision = hardwareRevision;
                              if (aCallback) {
                                  aCallback();
                              }
                          }];
}


- (void)readFirmwareRevisionWithCompletion:(RPDeviceUpdateCallback)aCallback {
    [LGUtils readDataFromCharactUUID:kCharacteristicFirmwareVersion
                         serviceUUID:kServiceDeviceInformation
                          peripheral:self.device
                          completion:^(NSData *data, NSError *error) {
                              NSString *firmwareRevision = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _firmwareRevision = firmwareRevision;
                              if (aCallback) {
                                  aCallback();
                              }
                          }];
}

- (void)readSoftwareRevisionWithCompletion:(RPDeviceUpdateCallback)aCallback {
    [LGUtils readDataFromCharactUUID:kCharacteristicSoftwareVersion
                         serviceUUID:kServiceDeviceInformation
                          peripheral:self.device
                          completion:^(NSData *data, NSError *error) {
                              NSString *softwareRevision = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              _softwareRevision = softwareRevision;
                              if (aCallback) {
                                  aCallback();
                              }
                          }];
}

- (void)writeFirmwareFrameWithCompletion:(NSData *)frameData
                              completion:(LGCharacteristicWriteCallback)aCallback {
    [LGUtils writeData:frameData
           charactUUID:kCharacteristicOTADataWithResponse
           serviceUUID:kServiceOTA
            peripheral:self.device
            completion:aCallback];
}

- (void)sendResetToDFU {
    const unsigned char dfuResetCommand = 3;

    [LGUtils writeData:[NSData dataWithBytes:&dfuResetCommand length:sizeof(dfuResetCommand)]
           charactUUID:kCharacteristicOTAControlNoResponse
           serviceUUID:kServiceOTA
            peripheral:self.device
            completion:nil];
}

- (void)sendReset {
    const unsigned char resetCommand = 1;

    [LGUtils writeData:[NSData dataWithBytes:&resetCommand length:sizeof(resetCommand)]
           charactUUID:kCharacteristicReset
           serviceUUID:kServiceControl
            peripheral:self.device
            completion:nil];
}


@end