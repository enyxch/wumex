//
//  WULoginViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 21.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WULoginViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldMail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;

@end
