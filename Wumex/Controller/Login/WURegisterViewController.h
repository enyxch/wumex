//
//  WURegisterViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 22.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JVFloatLabeledTextField.h"
#import "PECropViewController.h"

@interface WURegisterViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIImage *imageBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBackground;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *textFieldMail;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *textFieldConfirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonChoosePicture;
@property (weak, nonatomic) IBOutlet UILabel *labelChooseImage;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

@end
