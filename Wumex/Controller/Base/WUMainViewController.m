//
//  WUMainViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 21.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMainViewController.h"

@interface WUMainViewController ()

@end

@implementation WUMainViewController

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
    
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
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

- (void)setupNavBar
{
    [self.navigationItem setLeftBarButtonItem:self.searchBarNewItem animated:YES];
    
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    [self.navigationItem setRightBarButtonItem:searchBarItem animated:YES];
    
    self.navigationItem.titleView = self.segmentControl;
}

- (IBAction)search:(id)sender
{
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    [self.navigationItem setLeftBarButtonItem:searchBarItem animated:NO];
    
    [self.searchBar setFrame:CGRectMake(16, 0, 60, 44)];
    [self.searchBar layoutSubviews];
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.searchBar setFrame:CGRectMake(0, 0, 240, 44)];
        [self.searchBar layoutSubviews];
    } completion:nil];
    
    
    UIBarButtonItem *searchBarCancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSearch:)];
    [self.navigationItem setRightBarButtonItem:searchBarCancelItem animated:YES];
    
    self.navigationItem.titleView = nil;
    
    [self.searchBar becomeFirstResponder];
    
    isSearching = YES;
    [self.tableView reloadData];
}

- (IBAction)cancelSearch:(id)sender
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
    self.filteredList = @[].mutableCopy;
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.searchBar setFrame:CGRectMake(0, 0, 60, 44)];
        [self.searchBar layoutSubviews];
        self.navigationItem.leftBarButtonItem.width = 240;
    } completion:^(BOOL finished) {
        [self setupNavBar];
    }];
    
    isSearching = NO;
    [self.tableView reloadData];
}

@end
