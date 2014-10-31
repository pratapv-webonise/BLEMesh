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

@interface JoinMeshViewController ()

@end

@implementation JoinMeshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startPeriferal];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

#pragma mark
#pragma Periferal
-(void)startPeriferal{
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _peripheralManager.delegate =self;
    [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"updating charcterstics.. %d",peripheral.state);
    
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
     
        
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify  value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
        

        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        transferService.characteristics = @[_transferCharacteristic];
        
        [_peripheralManager addService:transferService];
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Connected to master..%@ %@",central,characteristic.value);
    
    NSLog(@"value peripheral --> %@",characteristic);
    
    self.masterConnectionLabel.text = @"Connected to master";
    //Now start scanning and finding new two devices
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sendInfomation) userInfo:nil repeats:YES];
 
}

#pragma mark
#pragma send data
-(void)sendInfomation{
    //data
    NSString *levl= @"periferal";
    NSData* data = [levl dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheralManager updateValue:data forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
}

-(NSDictionary *)gatherInfo{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    return dict;
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"read request...");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
     NSLog(@"write request... %@",[[requests lastObject] class]);
    
    CBATTRequest *request = [requests lastObject];
    
    NSString *myString = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
    NSLog(@"%@",myString);
    
}


@end
