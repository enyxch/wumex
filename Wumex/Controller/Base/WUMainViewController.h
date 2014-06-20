//
//  WUMainViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 21.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUMainViewController : UIViewController
{
    BOOL isSearching;
}

@property (strong, nonatomic) UISearchBar* searchBar;
@property (strong, nonatomic) UISegmentedControl* segmentControl;
@property (strong, nonatomic) UIBarButtonItem* searchBarNewItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *filteredList;

- (void)setupNavBar;
- (IBAction)search:(id)sender;
- (IBAction)cancelSearch:(id)sender;

@end
