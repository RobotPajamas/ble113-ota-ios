//
//  DeviceListTVC.m
//  ble113-ota
//
//  Created by Suresh Joshi on 15-03-07.
//  Copyright (c) 2015 Robot Pajamas. All rights reserved.
//


#import <MBProgressHUD/MBProgressHUD.h>
#import "DeviceSettingsVC.h"
#import "Models/SampleDevice.h"

@interface DeviceSettingsVC ()

/*
 * The outlet link to the picker which will be loaded with the available firmware files
 */
@property (weak, nonatomic) IBOutlet UIPickerView *firmwarePicker;

/*
 * The outlet link to the name of the connected Pavlok device
 */
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

/*
 * The outlet link to the current firmware version of the Pavlok device
 */
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;

/*
 * The action link for pressing the update button
 */
- (IBAction)updateFirmware:(UIButton *)sender;

/*
 * The .ota files which will fill the picker
 */
@property (strong, nonatomic) NSArray *otaFilePaths;

/*
 * The .ota files to be uploaded
 */
@property (strong, nonatomic) NSString *selectedOtaFilePath;

@end

@implementation DeviceSettingsVC


- (void)viewDidLoad {
    [super viewDidLoad];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.device connectWithTimeout:10 completion:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.device readDeviceInformationWithCompletion:^() {
            [[self firmwareVersionLabel] setText:self.device.firmwareRevision];
        }];
    }];

    // Fill the UIPicker backing store
    self.otaFilePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"ota" inDirectory:@"."];
    if ([self.otaFilePaths count] != 0) {
        [self setSelectedOtaFilePath:(self.otaFilePaths)[0]];
    }

    // Connect data
    self.firmwarePicker.dataSource = self;
    self.firmwarePicker.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*----------------------------------------------------*/
#pragma mark - UI Picker delegates
/*----------------------------------------------------*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.otaFilePaths count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [(self.otaFilePaths)[(NSUInteger) row] lastPathComponent];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Update current firmware file - convenience, instead of always needing to check what row we're on
    [self setSelectedOtaFilePath:(self.otaFilePaths)[(NSUInteger) row]];
}


- (IBAction)updateFirmware:(UIButton *)sender {
    // Verify with the user that they want to update the firmware
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"firmware_update", nil)
                                                    message:NSLocalizedString(@"firmware_verify", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"update", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // buttonIndex == 0 is a cancellation, buttonIndex == 1 is the go-ahead
    if(buttonIndex == 1)
    {
        [self startFirmwareUpdate];
    }
}

- (void)startFirmwareUpdate {
    // Create a progress indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeAnnularDeterminate];
    [hud setDetailsLabelText:NSLocalizedString(@"updating", nil)];

    // Extract the file bytes from the selected file
    NSData *fileData = [NSData dataWithContentsOfFile:_selectedOtaFilePath];

    // Async dispatch the firmware update... Callbacks will update the HUD
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self device] updateFirmware:fileData
                                progress:^(int currentFrame, int totalFrames) {
                                    if (currentFrame < totalFrames) {
                                        float progress = currentFrame / (float)totalFrames;
                                        hud.progress = progress;
                                    }
                                    else {
                                        hud.progress = 1.0;
                                    }
                                }
                              completion:^(int currentFrame, int totalFrames) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [hud hide:YES];
                                  });
                              }];
    });
}

@end