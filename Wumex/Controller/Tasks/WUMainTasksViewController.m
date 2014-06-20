//
//  WUMainTasksViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMainTasksViewController.h"

#import "WUTaskViewController.h"

@interface WUMainTasksViewController ()

@end

@implementation WUMainTasksViewController

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
        [self.tabBarItem setTitle:NSLocalizedString(@"Tasks", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_task"]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbar_task_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIHelper colorFromHex:TASK_COLOR]}
                                       forState:UIControlStateSelected];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    self.searchBar.tintColor = [UIHelper colorFromHex:TASK_COLOR];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"My tasks", nil), NSLocalizedString(@"All tasks", nil)]];
    [self.segmentControl setSelectedSegmentIndex:0];
    
    self.searchBarNewItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newTask:)];
    
    [self setupNavBar];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup when the view is about to made visible.
    if (self.navigationController) {
        if (self.navigationController.navigationBar) {
            [self.navigationController.navigationBar setBarTintColor:[UIHelper colorFromHex:TASK_COLOR]];
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

- (IBAction)newTask:(id)sender
{
    WUTaskViewController* taskVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WUTaskViewController"];
    taskVC.isEditMode = YES;
    [self.navigationController pushViewController:taskVC animated:YES];
}

@end
