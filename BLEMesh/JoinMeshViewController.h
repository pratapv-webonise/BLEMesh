//
//  JoinMeshViewController.h
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JoinMeshViewController : UIViewController<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate,UITextFieldDelegate>

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

@property(nonatomic,strong) NSString *thisDeviceLevel;

//data transfer operations
@property(nonatomic,strong) NSDictionary *masterPacketDictionary;

@property(nonatomic,strong) NSDictionary *slave1Dictionary;
@property(nonatomic,strong) NSDictionary *slave2Dictionary;

//position
@property (strong,nonatomic) CBMutableCharacteristic *positionCharacteristic;

//
@property(strong,nonatomic) IBOutlet UIButton *askPositionBtn;
-(IBAction)askPositionBtnClicked:(id)sender;

//
@property(nonatomic,strong) NSMutableDictionary *requestStatus;

@end
