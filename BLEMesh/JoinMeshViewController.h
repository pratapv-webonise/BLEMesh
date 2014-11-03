//
//  JoinMeshViewController.h
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JoinMeshViewController : UIViewController<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

//periferal
@property (strong,nonatomic) CBPeripheralManager *peripheralManager;
@property (strong,nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong,nonatomic) NSData *dataToSend;
@property (nonatomic,readwrite) NSInteger sendDataIndex;
@property (nonatomic,strong) IBOutlet UILabel *masterConnectionLabel;
@property (nonatomic,strong) IBOutlet UILabel *s1StatusLabel;
@property (nonatomic,strong) IBOutlet UILabel *s2StatusLabel;


@property(nonatomic,strong) NSMutableArray *connecteDevicesArray;

//central
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *discoveredPeripheral_1;
@property (nonatomic,strong) CBPeripheral *discoveredPeripheral_2;
@property (strong,nonatomic) NSMutableData *data;


@property(nonatomic,strong) NSMutableArray *detectedSlaveDevices;
@end
