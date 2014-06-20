//
//  WUMoreViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMoreViewController.h"
#import "WULoginViewController.h"
#import "WUHTTPClient.h"

@interface WUMoreViewController ()

@end

@implementation WUMoreViewController

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
        [self.tabBarItem setTitle:NSLocalizedString(@"More", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_more"]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbar_more_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIHelper colorFromHex:MORE_COLOR]}
                                       forState:UIControlStateSelected];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup when the view is about to made visible.
    if (self.navigationController) {
        if (self.navigationController.navigationBar) {
            [self.navigationController.navigationBar setBarTintColor:[UIHelper colorFromHex:MORE_COLOR]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        
        [[WUHTTPClient sharedClient] discardSession];
        
        WULoginViewController* viewController = [[WULoginViewController alloc] initWithNibName:@"WULoginViewController" bundle:nil];
        
        // Present ;
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:viewController animated:NO completion:^{
            
        }];
    }
}

@end
