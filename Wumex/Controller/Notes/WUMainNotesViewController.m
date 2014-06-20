//
//  WUMainNotesViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMainNotesViewController.h"

@interface WUMainNotesViewController ()

@end

@implementation WUMainNotesViewController

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
        [self.tabBarItem setTitle:NSLocalizedString(@"Notes", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_note"]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbar_note_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIHelper colorFromHex:NOTE_COLOR]}
                                       forState:UIControlStateSelected];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    self.searchBar.tintColor = [UIHelper colorFromHex:NOTE_COLOR];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"My notes", nil), NSLocalizedString(@"All notes", nil)]];
    [self.segmentControl setSelectedSegmentIndex:0];
    
    self.searchBarNewItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote:)];
    
    [self setupNavBar];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup when the view is about to made visible.
    if (self.navigationController) {
        if (self.navigationController.navigationBar) {
            //Custom NavBar
            [self.navigationController.navigationBar setBarTintColor:[UIHelper colorFromHex:NOTE_COLOR]];
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

- (IBAction)newNote:(id)sender
{
    
}

@end
