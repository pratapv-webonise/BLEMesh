//
//  CreateMeshViewController.m
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import "CreateMeshViewController.h"
#define TRANSFER_SERVICE_UUID           @"c6e00bee-5526-4d34-9efd-85b1e4562c4b"
#define TRANSFER_CHARACTERISTIC_UUID    @"0ae55ad5-4f16-4d41-8487-e7dd7e945f83"
#define NOTIFY_MTU 20
#import "CBUUID+String.h"

@interface CreateMeshViewController ()

@end

@implementation CreateMeshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //start central
    [self startCentral];
    
    _detectedDevices = [[NSMutableArray alloc]initWithCapacity:2];
    _finalDeviceList = [[NSMutableArray alloc]init];
    _positionArray = [[NSMutableArray alloc]init];
    _charArray = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma mark
#pragma AS A CENTRAL

-(void)startCentral{
    //start central
    dispatch_queue_t centralQueue = dispatch_queue_create("mycentralqueue", DISPATCH_QUEUE_SERIAL);
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state!=CBCentralManagerStatePoweredOn){
        NSLog(@"Bluetooth service is off...");
        return;
    }
    else
        if(central.state ==CBCentralManagerStatePoweredOn){
            NSLog(@"Bluetooth service is working...");
            NSLog(@"Scanning for devices.....");
            [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{

    
    NSLog(@"Connecting to %@ - advertisement data %@",peripheral.name,advertisementData);
    
    if(peripheral!=_discoveredPeripheral_1 && peripheral!= _discoveredPeripheral_2){
        NSLog(@"Periferal 1 found..");
        _discoveredPeripheral_1 = peripheral;
        [_centralManager connectPeripheral:peripheral options:nil];
        //1 device
        
        [_detectedDevices addObject:peripheral];
        [_tableView reloadData];
        [central stopScan];
    }
    else if(_discoveredPeripheral_2 == nil && peripheral!= _discoveredPeripheral_1) {
         NSLog(@"Periferal 2 found..");
        _discoveredPeripheral_2 = peripheral;
        [_centralManager connectPeripheral:peripheral options:nil];
         [_detectedDevices addObject:peripheral];
        [central stopScan];
        [_tableView reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}

- (void)cleanup {
    NSLog(@"Clean up...");
    //diconnect all devices
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
      NSLog(@"Discovered services %@ ",peripheral.services);
   
//      [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
   
    peripheral.delegate = self;
    
    if (peripheral.services) {
        [self peripheral:peripheral didDiscoverServices:nil];
    } else {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSLog(@"Charterstics DICOVERED");
    
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            //now write
            NSString *levl= @"0";
            NSData* data = [levl dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
        }
        else  {
            
            //Incoming position request
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [self positionArrayInitilaisation];
        }
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error %@",[error debugDescription]);
        return;
    }
    //Recive Final list of devices...
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]){
        
        [self getTree:peripheral Data:characteristic.value];
    
    }
    else{
        //update the position table
        NSDictionary *positionDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        
        NSLog(@"%@",positionDictionary);
        
        
        
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic{
    NSString *s= [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"didWriteValue characteristic.value: %@ ", s);
}

#pragma mark
#pragma arguments

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _finalDeviceList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _finalDeviceList[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

#pragma mark 
#pragma list of devices

-(void)getTree:(CBPeripheral *)peripheral Data:(NSData *)data{
    
    if(peripheral == _discoveredPeripheral_1){
        NSDictionary *slave1Data = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self getList:slave1Data];
    }
    else{
        NSDictionary *slave2Data = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self getList:slave2Data];
    }
}

-(void)getList:(NSDictionary *)dictionary{
    
    if(dictionary!=nil && ![dictionary isKindOfClass:[NSString class]]){
        
        [_finalDeviceList addObject:dictionary[@"name"]];
        
        if(dictionary[@"right_slave_dict"]!=nil && ![dictionary isKindOfClass:[NSString class]] ){
            [self getList:dictionary[@"right_slave_dict"]];
        }
        
        if(dictionary[@"left_slave_dict"]!=nil && ![dictionary isKindOfClass:[NSString class]] ){
            [self getList:dictionary[@"left_slave_dict"]];
        }
        
        [_tableView reloadData];
    }
}

-(void)positionArrayInitilaisation{
    
    for(int i = 0 ; i < _finalDeviceList.count ; i++ ){
        
        NSDictionary *t;
        
        if(i==0){
            
            t = @{
                  @"Position":@"1",
                  @"owner":[UIDevice currentDevice].identifierForVendor
                 };
            }
        else{
            t = @{
                  @"Position":@"0",
                  @"owner":@""
                };
        }
        
        [_positionArray addObject:t];
    }
}

@end

