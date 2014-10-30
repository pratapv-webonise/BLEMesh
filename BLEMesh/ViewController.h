//
//  ViewController.h
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface ViewController : UIViewController<UISearchControllerDelegate,UISearchDisplayDelegate>{
    AFHTTPRequestOperationManager *manager;
    BOOL isSearching;
}
@property(nonatomic,strong) NSMutableArray *searchResultsArray;
@property(nonatomic,strong) IBOutlet UITableView *tableView;
@end

