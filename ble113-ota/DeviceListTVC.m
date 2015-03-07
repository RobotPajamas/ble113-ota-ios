//
//  DeviceListTVC.m
//  ble113-ota
//
//  Created by Suresh Joshi on 15-03-07.
//  Copyright (c) 2015 Robot Pajamas. All rights reserved.
//


#import "DeviceListTVC.h"
#import "LGCentralManager.h"
#import "MBProgressHUD.h"
#import "SampleDevice.h"
#import "DeviceSettingsVC.h"


@interface DeviceListTVC ()

// List of BLE devices
@property(strong, nonatomic) NSArray *bleDevices;

@end

@implementation DeviceListTVC


- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(scanForDevices:)
                  forControlEvents:UIControlEventValueChanged];

    // Run once when page loads
    [self scanForDevices:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scanForDevices:(id)sender {
    // Do a scan for nearby BLE devices and update table view
    NSUInteger kBleScanInterval = 3;
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:kBleScanInterval
                                                         completion:^(NSArray *devices) {
                                                             [self.refreshControl endRefreshing];
                                                             NSArray* filteredDevices = [self filterPeripherals:devices];
                                                             [self setBleDevices:filteredDevices];
                                                             [self.tableView reloadData];
                                                         }];
}

/*
 * This function filters the incoming list of peripherals by their local name.
 * Specifically, it looks for a local name that contains the word "robot pajamas" (case insensitive)
 */
- (NSArray *) filterPeripherals: (NSArray *)peripherals
{
    // Exit early
    if ([peripherals count] == 0)
    {
        return peripherals;
    }

    NSString *kPredicateQuery = @"robot pajamas";
    NSPredicate *rpjPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", kPredicateQuery];
    NSMutableArray *filteredPeripherals = [NSMutableArray array];

    // Iterate through each object, matching on local names containing 'robot pajamas'
    [peripherals enumerateObjectsUsingBlock:^(LGPeripheral *peripheral, NSUInteger index, BOOL *stop)
    {
        NSString *localName = peripheral.advertisingData[@"kCBAdvDataLocalName"];
        if ([rpjPredicate evaluateWithObject:localName])
        {
            [filteredPeripherals addObject: peripheral];
        }
    }];

    return [filteredPeripherals copy];
}


# pragma mark - Table View datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bleDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    LGPeripheral *device = (self.bleDevices)[(NSUInteger) indexPath.row];
    cell.textLabel.text = (device.advertisingData)[@"kCBAdvDataLocalName"];
    return cell;
}

#pragma mark - Table view delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Find the selected cell in the usual way
    LGPeripheral *bleDevice = (self.bleDevices)[(NSUInteger) indexPath.row];
    SampleDevice *device = [[SampleDevice alloc] initWithDevice:bleDevice];
    [self performSegueWithIdentifier:@"goToSettings" sender:device];
}

# pragma mark Handle Segues

// This will get called too before the view appears
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToSettings"]) {

        // Get destination view and pass in device object
        DeviceSettingsVC *vc = [segue destinationViewController];
        [vc setDevice:sender];
    }
}


@end