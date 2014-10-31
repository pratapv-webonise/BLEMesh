//
//  CreateMeshViewController.h
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface CreateMeshViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate,UITableViewDataSource,UITableViewDelegate>

//base
@property(nonatomic,strong) NSMutableDictionary *meshDictionary;
@property(nonatomic,strong) IBOutlet UITableView *tableView;

//devices
@property(nonatomic,strong) NSMutableArray *detectedDevices;
@property(nonatomic,strong) NSMutableArray *charArray;

//periferal
@property (strong,nonatomic) CBPeripheralManager *peripheralManager;
@property (strong,nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong,nonatomic) NSData *dataToSend;
@property (nonatomic,readwrite) NSInteger sendDataIndex;

//central
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *discoveredPeripheral_1;
@property (nonatomic,strong) CBPeripheral *discoveredPeripheral_2;
@property (strong,nonatomic) NSMutableData *data;

//saved services
@property (nonatomic,strong) CBService *storedService;

@end
