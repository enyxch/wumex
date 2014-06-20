//
//  WURegisterViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 22.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WURegisterViewController.h"

#import "ModalAnimation.h"
#import "UIImage+ImageEffects.h"

#import "WUUsersHTTPRequestProvider.h"

@interface WURegisterViewController ()
{
    ModalAnimation *_modalAnimationController;
}

@property (nonatomic) UIPopoverController *popover;

@end

@implementation WURegisterViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.viewMain.layer.borderColor = [UIHelper colorFromHex:CHAT_COLOR].CGColor;
    self.viewMain.layer.borderWidth = 5.f;
    self.viewMain.layer.cornerRadius = 15.f;
    self.viewMain.layer.masksToBounds = YES;
    
    self.buttonFinish.layer.cornerRadius = 5.f;
    self.buttonFinish.layer.masksToBounds = YES;
    
    self.buttonEdit.layer.cornerRadius = 5.f;
    self.buttonEdit.layer.masksToBounds = YES;
    
    self.imageViewProfile.layer.masksToBounds = YES;
    
    [self.buttonEdit setHidden:YES];
    
    if (self.imageBackground) {
        self.imageViewBackground.image = self.imageBackground;
    }
    [self animationBegining];
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

- (void)animationBegining
{
    self.buttonClose.alpha = 0.f;
    CGRect endFrame = self.viewMain.frame;
    self.viewMain.frame = CGRectMake(endFrame.origin.x, self.view.frame.size.height, endFrame.size.width, endFrame.size.height);
    //Animate using spring animation
    [UIView animateWithDuration:1.f delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:0 animations:^{
        self.viewMain.frame = endFrame;
    } completion:^(BOOL finished) {
        self.buttonClose.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1);
        [UIView animateWithDuration:0.3f delay:0.1f usingSpringWithDamping:0.5f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveLinear animations:^{
            self.buttonClose.layer.transform = CATransform3DIdentity;
            self.buttonClose.alpha = 1.f;
        } completion:nil];
    }];
    [UIView transitionWithView:self.imageViewBackground
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageViewBackground.image = [self.imageBackground applyTransparenceEffect];
                    } completion:NULL];
}

- (void)animationEnd
{
    self.buttonClose.alpha = 0.f;
    
    //Grab a snapshot of the modal view for animating
    UIView *snapshot = [self.viewMain snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = self.viewMain.frame;
    [self.view addSubview:snapshot];
    [self.view bringSubviewToFront:snapshot];
    [self.viewMain removeFromSuperview];
    
    //Set the snapshot's anchor point for CG transform
    CGRect originalFrame = snapshot.frame;
    snapshot.layer.anchorPoint = CGPointMake(0.0, 1.0);
    snapshot.frame = originalFrame;
    
    //Animate using keyframe animation
    [UIView animateKeyframesWithDuration:1.3 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.15 animations:^{
            //90 degrees (clockwise)
            snapshot.transform = CGAffineTransformMakeRotation(M_PI * -1.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.10 animations:^{
            //180 degrees
            snapshot.transform = CGAffineTransformMakeRotation(M_PI * 1.0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.20 animations:^{
            //Swing past, ~225 degrees
            snapshot.transform = CGAffineTransformMakeRotation(M_PI * 1.3);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.45 relativeDuration:0.20 animations:^{
            //Swing back, ~140 degrees
            snapshot.transform = CGAffineTransformMakeRotation(M_PI * 0.8);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.65 relativeDuration:0.35 animations:^{
            //Spin and fall off the corner
            //Fade out the cover view since it is the last step
            CGAffineTransform shift = CGAffineTransformMakeTranslation(180.0, 0.0);
            CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI * 0.5);
            snapshot.transform = CGAffineTransformConcat(shift, rotate);
        }];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [UIView transitionWithView:self.imageViewBackground
                      duration:1.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageViewBackground.image = self.imageBackground;
                    } completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self animationEnd];
}

- (IBAction)finish:(id)sender
{
    if ([self validForm]) {
        
        WUUser *user = [[WUUser alloc] init];
        user.email = self.textFieldMail.text;
        user.password = self.textFieldPassword.text;
        
        WURegisterViewController* __weak weakSelf = self;
        
        [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Registration...", nil)];
        [[WUUsersHTTPRequestProvider sharedInstance] registerUser:user success:^(NSDictionary *response) {
            
            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
            
            NSString* token = response[@"token"];
            user.token = token;
            
            [[WUHTTPClient sharedClient] setLoggedInUser:user];
            [[WUHTTPClient sharedClient] saveSession];
            
            [weakSelf animationEnd];
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Registred", nil) forDelay:1];
            
        } failure:^(NSString *errorCode) {
            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
            [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
        }];
    }
}

- (BOOL)validForm
{
    BOOL result = YES;
    NSString *title, *message;
    if ([self.textFieldMail.text isEqualToString:@""]) {
        result = NO;
        title = NSLocalizedString(@"Mail", @"title");
        message = NSLocalizedString(@"We need an email to create an account", @"message");
        
    } else if ([self.textFieldPassword.text isEqualToString:@""]) {
        result = NO;
        title = NSLocalizedString(@"Password", @"title");
        message = NSLocalizedString(@"We need a password to create an account", @"message");
        
    } else if ([self.textFieldConfirmPassword.text isEqualToString:@""]) {
        result = NO;
        title = NSLocalizedString(@"Password", @"title");
        message = NSLocalizedString(@"You have to confirm your password", @"message");
        
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldConfirmPassword.text]) {
        result = NO;
        self.textFieldPassword.floatingLabelTextColor = [UIColor redColor];
        [self.textFieldPassword setNeedsLayout];
        self.textFieldConfirmPassword.floatingLabelTextColor = [UIColor redColor];
        [self.textFieldConfirmPassword setNeedsLayout];
        title = NSLocalizedString(@"Password", @"title");
        message = NSLocalizedString(@"The confirmation password doesn't match with the original", @"message");
    }
    
    if (!result) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:NSLocalizedString(@"Ok", nil)
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        [alertView show];
    }
    return result;
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageViewProfile.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action methods

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.imageViewProfile.image;
    controller.toolbarHidden = YES;
    controller.cropAspectRatio = 1.f;
    controller.keepingCropAspectRatio = YES;    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)cameraButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
}

#pragma mark - Private methods

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UIActionSheetDelegate methods

/*
 Open camera or photo album.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
        [self showCamera];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

/*
 Open PECropViewController automattically when image selected.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.imageViewProfile.image = image;
        [self.buttonEdit setHidden:NO];
        [self.labelChooseImage setHidden:YES];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];
        }];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[JVFloatLabeledTextField class]]) {
        ((JVFloatLabeledTextField*)textField).floatingLabelTextColor = [UIColor grayColor];
    }
}

@end
