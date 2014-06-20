//
//  WULoginViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 21.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WULoginViewController.h"

#import "IQUIView+IQKeyboardToolbar.h"
#import "WURegisterViewController.h"
#import "WUSessionHTTPRequestProvider.h"

@interface WULoginViewController ()

@end

@implementation WULoginViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[WUHTTPClient sharedClient] hasValidSession]) {
        [self dismissViewControllerAnimated:YES completion:^{ }];
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

- (IBAction)login:(id)sender
{
    NSString *email = self.textFieldMail.text;
    NSString *password = self.textFieldPassword.text;
    
    WULoginViewController* __weak weakSelf = self;
    
    [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Logging...", nil)];
    [[WUSessionHTTPRequestProvider sharedInstance] loginWithEmail:email password:password success:^(NSDictionary *response) {
        
        NSString* token = response[@"token"];
        
        WUUser *user = [[WUUser alloc] init];
        user.token = token;
        
        [[WUHTTPClient sharedClient] setLoggedInUser:user];
        [[WUHTTPClient sharedClient] saveSession];
        
        [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Logged", nil) forDelay:1];
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{ }];
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (IBAction)registration:(id)sender
{
    WURegisterViewController* viewController = [[WURegisterViewController alloc] initWithNibName:@"WURegisterViewController" bundle:nil];
    
    // Present ;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    viewController.imageBackground = [UIHelper imageWithView:self.view];
    [self presentViewController:viewController animated:NO completion:nil];
}

@end
