//
//  ProfileViewController.h
//  ChatHeads
//
//  Created by Nicolas Bonnet on 16.04.14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQGanttView.h"
#import "MBSwitch.h"

@interface WUProfileViewController : UIViewController <UIScrollViewDelegate>
{
    UIInterfaceOrientation authorizedOrientation;
    BOOL isLandscape;
}

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBackground;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelLocalisation;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLocalisation;
@property (weak, nonatomic) IBOutlet UIView *viewNameLocalisation;

@property (weak, nonatomic) IBOutlet UIView *viewBackgroundLong;
@property (weak, nonatomic) IBOutlet UIView *viewBackgroundShort;

@property (weak, nonatomic) IBOutlet UIView *viewProjectShort;
@property (weak, nonatomic) IBOutlet UIView *viewTaskShort;
@property (weak, nonatomic) IBOutlet UIView *viewNoteShort;
@property (weak, nonatomic) IBOutlet UIView *viewNameShort;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfileShort;

@property (weak, nonatomic) IBOutlet UIView *viewContainerGanttView;
@property (strong, nonatomic) IQGanttView *ganttView;
@property (strong, nonatomic) UIView *fullScreenView;

@property (weak, nonatomic) IBOutlet MBSwitch *mbSwitchCall;
@property (weak, nonatomic) IBOutlet MBSwitch *mbSwitchMail;

//Long
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProjectLong;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTaskLong;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewNoteLong;
@property (weak, nonatomic) IBOutlet UILabel *labelProjectLong;
@property (weak, nonatomic) IBOutlet UILabel *labelTaskLong;
@property (weak, nonatomic) IBOutlet UILabel *labelNoteLong;
@property (weak, nonatomic) IBOutlet UILabel *labelNbProjectLong;
@property (weak, nonatomic) IBOutlet UILabel *labelNbTaskLong;
@property (weak, nonatomic) IBOutlet UILabel *labelNbNoteLong;

//Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintTopViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBetweenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightBackground;

@end
