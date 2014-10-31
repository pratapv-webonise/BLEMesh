//
//  ViewController.m
//  BLEMesh
//
//  Created by Mac-4 on 30/10/14.
//  Copyright (c) 2014 WeboniseLab. All rights reserved.
//

#import "ViewController.h"
#import "YouTubeCell.h"
#import "UIImageView+AFNetworking.h"
#import "CreateMeshViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [AFHTTPRequestOperationManager manager];
    [self searchYoutubeVideosForTerm:@"apple"];
    _searchResultsArray = [[NSMutableArray alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark
#pragma loadData

-(void)searchYoutubeVideosForTerm:(NSString*)term
{
    if (isSearching) {
        [manager.operationQueue cancelAllOperations];
    }
    
    

    _searchResultsArray= [[NSMutableArray alloc]init];
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* searchCall = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=20&alt=json", term];
    
    
    [manager GET:searchCall parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _searchResultsArray = responseObject[@"feed"][@"entry"];
        [_tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"something went wrong!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
 }

#pragma mark
#pragma tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchResultsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *tempDict = _searchResultsArray[indexPath.row];
    ;
    
    YouTubeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[YouTubeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.videoTitleLabel.text = tempDict[@"title"][@"$t"];
    
    [cell.videoImageView setImageWithURL:[NSURL URLWithString:[[tempDict[@"media$group"][@"media$thumbnail"]objectAtIndex:0]valueForKey:@"url"]]];
    
    NSString *s = tempDict[@"media$group"][@"yt$duration"][@"seconds"];
    
    float t =  [s floatValue] /60;
    cell.playTimeLabel.text = [NSString stringWithFormat:@"%.2f",t];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreateMeshViewController *createMesh = [storyboard instantiateViewControllerWithIdentifier:@"CreateMeshViewController"];
    createMesh.meshDictionary = _searchResultsArray[indexPath.row];
    [self.navigationController pushViewController:createMesh animated:YES];
}



@end
