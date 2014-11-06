//
//  JoinMeshViewController.m
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import "JoinMeshViewController.h"
#define TRANSFER_SERVICE_UUID           @"c6e00bee-5526-4d34-9efd-85b1e4562c4b"
#define TRANSFER_CHARACTERISTIC_UUID    @"0ae55ad5-4f16-4d41-8487-e7dd7e945f83"


#define POSITION_SERVICE_UUID           @"POSITION-SERVICE"
#define POSITION_CHARACTERISTIC_UUID    @"POSITION-CHARACTERISTIC"

@interface JoinMeshViewController ()

@end

@implementation JoinMeshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self startPeriferal];
    _requestStatus = [[NSMutableDictionary alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

#pragma mark
#pragma Periferal
-(void)startPeriferal{
   
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _peripheralManager.delegate =self;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
      
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify  value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        //position characterstic
        self.positionCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:POSITION_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify  value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
        
       
        transferService.characteristics = @[_transferCharacteristic,_positionCharacteristic];
        [_peripheralManager addService:transferService];

    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Connected to master..%@ %@",central,characteristic.value);

    self.masterConnectionLabel.text = @"Connected to master";
    //Now start scanning and finding new two devices
    
     NSString *name = @"";
     name = [UIDevice currentDevice].name;
    
    NSString *level = @"";
    level = self.thisDeviceLevel;
    
    
    NSDictionary *t   = @{@"name":name,
                                @"Level":_thisDeviceLevel,
                                @"right_slave_dict":@"",
                                @"Left_salve_dict":@""
                                };
    
    [self.peripheralManager updateValue:[self dictionaryToData:t] forCharacteristic:_transferCharacteristic onSubscribedCentrals:nil];
    
    [self startSlaveCentral];
}

#pragma mark
#pragma send data

-(NSDictionary *)gatherInfo{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    return dict;
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"read request...");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
     NSLog(@"write request... %@",[[requests lastObject] class]);
    
    CBATTRequest *request = [requests objectAtIndex:0];
    
    //check for charcterstic
     if ([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]){
         _thisDeviceLevel = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
         _thisDeviceLevel =[NSString stringWithFormat:@"%d",[_thisDeviceLevel intValue] + 1];
     }
     else if([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:POSITION_CHARACTERISTIC_UUID]]){
         //forward to slave
         [self processPostionRequest:peripheral request:request];
     }
    
    NSLog(@"%@",_thisDeviceLevel);
}


//-------------------------------------------------------------------------------------------------/

-(void)startSlaveCentral{
    dispatch_queue_t centralQueue = dispatch_queue_create("mycentralqueue", DISPATCH_QUEUE_SERIAL);
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
}

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
            [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stopScanningAfter30Sec) userInfo:nil repeats:NO];
        }
}

-(void)stopScanningAfter30Sec{
    [_centralManager stopScan];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"Connecting to %@ - advertisement data %@",peripheral.name,advertisementData);
    if(peripheral!=_discoveredPeripheral_1 && peripheral!= _discoveredPeripheral_2){
        NSLog(@"Periferal 1 found..");
        _discoveredPeripheral_1 = peripheral;
        [_centralManager connectPeripheral:peripheral options:nil];
        //1 device
        
        [_detectedSlaveDevices addObject:peripheral];
        [central stopScan];
    }
    else if(_discoveredPeripheral_2 == nil && peripheral!= _discoveredPeripheral_1) {
        NSLog(@"Periferal 2 found..");
        _discoveredPeripheral_2 = peripheral;
        [_centralManager connectPeripheral:peripheral options:nil];
        [_detectedSlaveDevices addObject:peripheral];
        [central stopScan];
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
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    NSLog(@"Discovered services %@",peripheral.services);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSLog(@"SERVICES DISCOVERED.....");
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
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error %@",[error debugDescription]);
        return;
    }
    
    if(peripheral == _discoveredPeripheral_1){
        _slave1Dictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        NSLog(@"Data from slave 1 %@",_slave1Dictionary);
        
    }
    else{
        _slave2Dictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        NSLog(@"Data from slave 2 %@",_slave2Dictionary);
    }
   
    [self sendStatusToMaster:characteristic.value];
}

#pragma mark
#pragma data transferoperaions

-(void)sendStatusToMaster :(NSData *)data{
    //if this current device have any slave than we will recive data from slave here..
    //send this data to master
    
    NSString *thisDeviceName = [[UIDevice currentDevice] name];
    
    _masterPacketDictionary = @{@"name":thisDeviceName,
                                @"Level":_thisDeviceLevel,
                                @"right_slave_dict":_slave1Dictionary,
                                @"Left_salve_dict":_slave2Dictionary
                                };
    
    NSLog(@"MasterPacket %@",_masterPacketDictionary);
   
    [self.peripheralManager updateValue:[self dictionaryToData:_masterPacketDictionary] forCharacteristic:_transferCharacteristic onSubscribedCentrals:nil];
    
}

-(NSData *)dictionaryToData:(NSDictionary*)dict{
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:dict
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
    return data1;
}


-(NSDictionary*)dataToDictionary:(NSData*)data{
    return  [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:nil];
    
}

#pragma mark
#pragma Position alert

-(IBAction)askPositionBtnClicked:(id)sender{
    
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Enter the position" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UITextField *textfield =  [alertView textFieldAtIndex: 0];
    NSLog(@"Requested Position %@",textfield.text);
    
    NSDictionary *positionDictionary = @{
                                         @"Position":textfield.text,
                                         @"Device_id":[[[UIDevice currentDevice] identifierForVendor]UUIDString]
                                         };

    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    else {
        [self.peripheralManager updateValue:[self dictionaryToData:positionDictionary] forCharacteristic:self.positionCharacteristic onSubscribedCentrals:nil];
    }
}

#pragma mark
#pragma position request process

-(void)processPostionRequest:(CBPeripheralManager *)peripheral request:(CBATTRequest *)request{
    NSDictionary *dictionary = [self dataToDictionary:request.value];
    
    /*  @"Status":@"Accepted",
     @"Position":position,
     @"Device_id":deviceid
     */
    
    if([dictionary[@"Device_id"] isEqualToString:[[UIDevice currentDevice].identifierForVendor UUIDString]]){
        NSLog(@"Request is for current device");
        [self showPositionRequestStatus:dictionary];
    }else{
        [self forwardRequest_Peripheral:peripheral data:dictionary];
    }
    
}

-(void)forwardRequest_Peripheral:(CBPeripheralManager *)p data:(NSDictionary*)dictionary{
    
}

-(void)showPositionRequestStatus:(NSDictionary *)dictionary{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:dictionary[@"Status"] message:[NSString stringWithFormat:@"Your request for the position %@",dictionary[@"Position"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
