//
//  WUMainChatViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMainChatViewController.h"

#import "ChatRoomCell.h"

@interface WUMainChatViewController ()

@end

@implementation WUMainChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.tabBarItem) {
        [self.tabBarItem setTitle:NSLocalizedString(@"Chat", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_chat"]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbar_chat_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIHelper colorFromHex:CHAT_COLOR]}
                                       forState:UIControlStateSelected];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    self.searchBar.tintColor = [UIHelper colorFromHex:CHAT_COLOR];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"My chats", nil), NSLocalizedString(@"All chats", nil)]];
    [self.segmentControl setSelectedSegmentIndex:0];
    self.searchBarNewItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newChat:)];
    
    [self setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup when the view is about to made visible.
    if (self.navigationController) {
        if (self.navigationController.navigationBar) {
            [self.navigationController.navigationBar setBarTintColor:[UIHelper colorFromHex:CHAT_COLOR]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath
{
    return 65.0f;
}

- (UITableViewCell*)tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    if (indexPath.row % 3 == 0) {
        ChatRoomCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatRoomCell"];
        
        if (cell == nil) {
            cell = [ChatRoomCell sharedCell];
        }
        [cell setImgFirstImage:[self getRandomSampleImage]];
        [cell setTitle:@"ChatRoomCell"];
        
        return cell;
    } else if (indexPath.row % 3 == 1) {
        ChatRoomTwoCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatRoomTwoCell"];
        
        if (cell == nil) {
            cell = [ChatRoomTwoCell sharedCell];
        }
        [cell setImgFirstImage:[self getRandomSampleImage]];
        [cell setImgSecondImage:[self getRandomSampleImage]];
        [cell setTitle:@"ChatRoomTwoCell"];
        
        return cell;
    } else {
        ChatRoomThreeCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChatRoomThreeCell"];
        
        if (cell == nil) {
            cell = [ChatRoomThreeCell sharedCell];
        }
        [cell setImgFirstImage:[self getRandomSampleImage]];
        [cell setImgSecondImage:[self getRandomSampleImage]];
        [cell setImgThirdImage:[self getRandomSampleImage]];
        [cell setTitle:@"ChatRoomThreeCell"];
        
        return cell;
    }
    
    return nil;
}

- (UIImage*)getRandomSampleImage
{
    NSArray* arrayImage = @[[UIImage imageNamed:@"profile1"], [UIImage imageNamed:@"profile2"], [UIImage imageNamed:@"profile3"], [UIImage imageNamed:@"profile4"], [UIImage imageNamed:@"profile5"]];
    int i = arc4random() % 5;
    return arrayImage[i];
}

#pragma mark - Other methode

- (IBAction)newChat:(id)sender
{
    
}

@end
