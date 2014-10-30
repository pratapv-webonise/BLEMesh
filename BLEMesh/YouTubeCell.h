//
//  YouTubeCell.h
//  MultiBluetoothSync
//
//  Created by Mac-4 on 28/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTubeCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UIImageView *videoImageView;
@property(nonatomic,strong) IBOutlet UILabel *playTimeLabel;
@property(nonatomic,strong) IBOutlet UILabel *videoTitleLabel;
@property(nonatomic,strong) IBOutlet UIView *v;
@end
