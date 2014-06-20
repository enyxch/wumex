//
//  ProfileViewController.m
//  ChatHeads
//
//  Created by Nicolas Bonnet on 16.04.14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import "WUProfileViewController.h"

#import "IQCalendarDataSource.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"

#import "OLGhostAlertView.h"
#import "MRoundedButton.h"

#import "NSBKeyframeAnimation.h"
#import "UIViewController+ScrollingNavbar.h"
#import "WUTask.h"
#import "WULabel.h"

#import "WULabelHTTPRequestProvider.h"
#import "WUTaskHTTPRequestProvider.h"

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size

@interface WUProfileViewController () <WYPopoverControllerDelegate>
{
    BOOL isShort;
    WYPopoverController *anotherPopoverController;
}

@property (strong, nonatomic) MRoundedButton *buttonCall;
@property (strong, nonatomic) MRoundedButton *buttonMail;
@property (strong, nonatomic) NSArray *listOfLabels;
@property (strong, nonatomic) NSArray *listOfTask;

@end

@implementation WUProfileViewController

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
    
    
	// Just call this line to enable the scrolling navbar
//	[self followScrollView:self.scrollView withDelay:0];
    
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.bounds.size.width / 2;
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.borderWidth = 4.0f;
    self.imageViewProfile.layer.borderColor = [UIHelper colorFromHex:CHAT_COLOR].CGColor;
    
    authorizedOrientation = (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
    
    MRHollowBackgroundView *backgroundView = [[MRHollowBackgroundView alloc] initWithFrame:self.viewTop.bounds];
    backgroundView.foregroundColor = [UIColor clearColor];
    [self.viewTop addSubview:backgroundView];
    [self.viewTop sendSubviewToBack:backgroundView];
    
    CGRect buttonRect = CGRectMake(240, 20, 40, 40);
    
    self.buttonCall = [[MRoundedButton alloc] initWithFrame:buttonRect
                                                       buttonStyle:MRoundedButtonCentralImage
                                              appearanceIdentifier:@"1"];
    self.buttonCall.imageView.image = [UIImage imageNamed:@"call"];
    [self.buttonCall addTarget:self action:@selector(goToCall) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:self.buttonCall];
    
    CGRect buttonRect2 = CGRectMake(240, 70, 40, 40);
    
    self.buttonMail = [[MRoundedButton alloc] initWithFrame:buttonRect2
                                                       buttonStyle:MRoundedButtonCentralImage
                                              appearanceIdentifier:@"1"];
    self.buttonMail.imageView.image = [UIImage imageNamed:@"email"];
    [self.buttonMail addTarget:self action:@selector(goToMail) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:self.buttonMail];
    
    
    self.viewBackgroundShort.layer.opacity = 0.f;
        
    self.imageViewBackground.layer.masksToBounds = YES;
    
    CGFloat yPos = 300;
    while (yPos+21 < self.viewBottom.frame.size.height) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, yPos, 200, 21)];
        label.text = NSStringFromCGRect(label.frame);
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor darkGrayColor];
        [self.viewBottom addSubview:label];
        
        yPos += 121;
    }
    
    self.ganttView = [[IQGanttView alloc] initWithFrame:self.viewContainerGanttView.bounds];
    [self.viewContainerGanttView addSubview:self.ganttView];
    
    self.ganttView.layer.cornerRadius = 10;
    self.ganttView.layer.masksToBounds = YES;
    
    [self.ganttView setDefaultRowHeight:30];
    
    [self loadTaskAndLabel];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.ganttView addGestureRecognizer:doubleTap];
    
    self.mbSwitchCall.textOn = @"Call Nicolas Bonnet";
    self.mbSwitchCall.textOff = @"Call: +41 52 222 04 04";
    self.mbSwitchCall.textOffColor = [UIColor darkGrayColor];
    self.mbSwitchCall.textOnColor = [UIColor whiteColor];
    [self.mbSwitchCall setTintColor:[UIColor colorWithRed:94./255 green:204./255 blue:130./255 alpha:1.00f]];
    [self.mbSwitchCall setOnTintColor:[UIColor colorWithRed:0./255 green:194./255 blue:64./255 alpha:1.00f]];
    [self.mbSwitchCall setOffTintColor:[UIColor colorWithRed:255./255 green:255./255 blue:255./255 alpha:1.00f]];
    
    self.mbSwitchMail.textOn = @"Send a mail";
    self.mbSwitchMail.textOff = @"Email: nicolas.bonnet@enyx.ch";
    self.mbSwitchMail.textOffColor = [UIColor darkGrayColor];
    self.mbSwitchMail.textOnColor = [UIColor whiteColor];
    [self.mbSwitchMail setTintColor:[UIColor colorWithRed:0.58f green:0.65f blue:0.65f alpha:1.00f]];
    [self.mbSwitchMail setOnTintColor:[UIColor colorWithRed:105./255 green:105./255 blue:105./255 alpha:1.00f]];
    [self.mbSwitchMail setOffTintColor:[UIColor colorWithRed:255./255 green:255./255 blue:255./255 alpha:1.00f]];
    
    [self startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self showNavBarAnimated:NO];
}

- (void)loadTaskAndLabel
{
    WUProfileViewController * __weak weakSelf = self;
    
    [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Uploading tasks", nil)];
    [[WUTaskHTTPRequestProvider sharedInstance] getTasksWithProjectId:[NSNumber numberWithInt:11] success:^(NSDictionary *response) {
        
        weakSelf.listOfTask = [NSMutableArray arrayWithArray:response[@"tasks"]];
        
        [[WULabelHTTPRequestProvider sharedInstance] getLabelsWithProjectId:[NSNumber numberWithInt:11] success:^(NSDictionary *response) {
            
            weakSelf.listOfLabels = [NSMutableArray arrayWithArray:response[@"labels"]];
            
            [weakSelf fillLabelsWithTasks];
            
            
            for (WULabel* label in self.listOfLabels) {
                [weakSelf.ganttView addRow:label];
            }
            
            
            IQGanttViewTimeWindow scaleWindow = self.ganttView.scaleWindow;
            scaleWindow.windowStart = scaleWindow.viewStart - 60*60*24*10;
            scaleWindow.windowEnd = scaleWindow.viewStart + 60*60*24*40;
            scaleWindow.viewSize = 2000000 * 0.5;
            [weakSelf.ganttView setScaleWindow:scaleWindow];
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Tasks uploaded", nil) forDelay:1];
            
        } failure:^(NSString *errorCode) {
            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
            [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
        }];
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)fillLabelsWithTasks
{
    for (WULabel* label in self.listOfLabels) {
        for (WUTask* task in self.listOfTask) {
            if ([task.labelId intValue] == [label.labelId intValue]) {
                [label addTask:task];
            }
        }
    }
}


- (void)startAnimation
{

//    CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    animateOnColor.duration = 0.7;
//    animateOnColor.fromValue = @0;
//    animateOnColor.toValue = @1;
//    animateOnColor.removedOnCompletion = NO;
//    animateOnColor.fillMode = kCAFillModeForwards;
//    [self.imageViewLocalisation.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
    
    
    self.imageViewProfile.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1);
    [UIView animateWithDuration:1.2f delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageViewProfile.layer.transform = CATransform3DIdentity;
    } completion:nil];
    
    self.buttonCall.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
    self.buttonCall.layer.opacity = 0.f;
    [UIView animateWithDuration:1.0f delay:0.1f usingSpringWithDamping:0.5f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveLinear animations:^{
        self.buttonCall.layer.transform = CATransform3DIdentity;
        self.buttonCall.layer.opacity = 1.f;
    } completion:nil];
    
    self.buttonMail.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
    self.buttonMail.layer.opacity = 0.f;
    [UIView animateWithDuration:1.0f delay:0.5f usingSpringWithDamping:0.5f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveLinear animations:^{
        self.buttonMail.layer.transform = CATransform3DIdentity;
        self.buttonMail.layer.opacity = 1.f;
    } completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [self animateLabelShowText:self.labelName.text inLabel:self.labelName withDuration:1.2f toRight:YES];
                   });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [self animateLabelShowText:self.labelLocalisation.text inLabel:self.labelLocalisation withDuration:1.2f toRight:YES];
                   });
    
    NSBKeyframeAnimation *animation = [NSBKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
                                                                        duration:1.
                                                                      startValue:-150
                                                                        endValue:0
                                                                        function:NSBKeyframeAnimationFunctionEaseOutBounce];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.imageViewLocalisation.layer addAnimation:animation forKey:@"transform.translation.y"];
    
    //Project
    self.imageViewProjectLong.layer.anchorPoint = CGPointMake(0, 0);
    self.imageViewProjectLong.layer.transform = CATransform3DRotate(CATransform3DMakeTranslation(-250, -self.imageViewProjectLong.bounds.size.height, 0), -M_PI_2, 0, 0, 1);
    [UIView animateWithDuration:1.1f delay:0.3f usingSpringWithDamping:0.8f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageViewProjectLong.layer.transform = CATransform3DMakeTranslation(-self.imageViewProjectLong.bounds.size.width, -self.imageViewProjectLong.bounds.size.height, 0);
    } completion:nil];
    
    self.labelNbProjectLong.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.5, 0.5, 1), M_PI, 0, 0, 1);
    self.labelNbProjectLong.layer.opacity = 0.f;
    [UIView animateWithDuration:0.8f delay:0.5f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelNbProjectLong.layer.transform = CATransform3DIdentity;
        self.labelNbProjectLong.layer.opacity = 1.f;
    } completion:nil];
    
    self.labelProjectLong.layer.transform = CATransform3DMakeTranslation (-320, 0, 0);
    [UIView animateWithDuration:1.f delay:0.3f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelProjectLong.layer.transform = CATransform3DIdentity;
    } completion:nil];
    
    
    //Task
    self.imageViewTaskLong.layer.transform = CATransform3DMakeTranslation(0, 150, 0);
    self.imageViewTaskLong.layer.opacity = 0.f;
    [UIView animateWithDuration:1.0f delay:0.7f usingSpringWithDamping:0.5f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageViewTaskLong.layer.transform = CATransform3DIdentity;
        self.imageViewTaskLong.layer.opacity = 1.f;
    } completion:nil];
    
    self.labelNbTaskLong.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.5, 0.5, 1), M_PI+0.1, 0, 0, -1);
    self.labelNbTaskLong.layer.opacity = 0.f;
    [UIView animateWithDuration:0.8f delay:0.6f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelNbTaskLong.layer.transform = CATransform3DScale(CATransform3DRotate(self.labelNbTaskLong.layer.transform, M_PI-0.1, 0, 0, -1), 2, 2, 1);
        self.labelNbTaskLong.layer.opacity = 1.f;
    } completion:nil];
    
    self.labelTaskLong.layer.transform = CATransform3DMakeTranslation (0, -200, 0);
    self.labelTaskLong.layer.opacity = 0.f;
    [UIView animateWithDuration:1.2f delay:0.7f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelTaskLong.layer.transform = CATransform3DIdentity;
        self.labelTaskLong.layer.opacity = 1.f;
    } completion:nil];
    
    
    //Note
    self.imageViewNoteLong.layer.anchorPoint = CGPointMake(1, 0);
    self.imageViewNoteLong.layer.transform = CATransform3DRotate(CATransform3DMakeTranslation(250, -self.imageViewProjectLong.bounds.size.height, 0), M_PI_2, 0, 0, 1);
    [UIView animateWithDuration:1.3f delay:0.4f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageViewNoteLong.layer.transform = CATransform3DMakeTranslation(self.imageViewNoteLong.bounds.size.width, -self.imageViewNoteLong.bounds.size.height, 0);
    } completion:nil];
    
    self.labelNbNoteLong.layer.transform = CATransform3DRotate(CATransform3DMakeScale(0.5, 0.5, 1), M_PI, 0, 0, 1);
    self.labelNbNoteLong.layer.opacity = 0.f;
    [UIView animateWithDuration:0.8f delay:0.4f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelNbNoteLong.layer.transform = CATransform3DIdentity;
        self.labelNbNoteLong.layer.opacity = 1.f;
    } completion:nil];
    
    self.labelNoteLong.layer.transform = CATransform3DMakeTranslation (320, 0, 0);
    [UIView animateWithDuration:1.2f delay:0.3f usingSpringWithDamping:0.6f initialSpringVelocity:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
        self.labelNoteLong.layer.transform = CATransform3DIdentity;
    } completion:nil];
}

- (void) goToCall
{
    [self.scrollView setContentOffset:CGPointMake(0, 500) animated:YES];
}

- (void) goToMail
{
    [self.scrollView setContentOffset:CGPointMake(0, 700) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doubleTapped:(UITapGestureRecognizer*)gesture
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (isLandscape ) {
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//            [self.ganttView removeFromSuperview];
            [self.fullScreenView removeFromSuperview];
            self.fullScreenView = nil;
            self.ganttView.frame = self.viewContainerGanttView.bounds;
            
            self.ganttView.layer.cornerRadius = 10;
            [self.viewContainerGanttView addSubview:self.ganttView];
            [self.ganttView layoutSubviews];
            isLandscape = NO;
        } else {
            OLGhostAlertView *advice = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"Advice", @"Title of a messageBox. The message : Change the orientation of your device to Portrait to leave this view.") message:NSLocalizedString(@"Change the orientation of your device to Portrait to leave this view.", @"Message of a messageBox. The title : Advice") timeout:3 dismissible:YES];
            advice.style = OLGhostAlertViewStyleDark;
            [advice showInView:self.fullScreenView];
        }
    } else {
        
        isLandscape = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
//        [self.ganttView removeFromSuperview];
        self.ganttView.transform = CGAffineTransformIdentity;
        
        self.fullScreenView = [[UIView alloc] init];
        self.fullScreenView.backgroundColor = [UIColor clearColor];
        
        [self.fullScreenView addSubview:self.ganttView];
        self.fullScreenView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        
        self.fullScreenView.frame = [UIScreen mainScreen].bounds;
        self.ganttView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        self.ganttView.layer.cornerRadius = 0;
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.fullScreenView];
    }
    
}

- (IBAction)redoStartAnnimation:(id)sender
{
    [self startAnimation];
}

- (void)animateLabelShowText:(NSString*)newText inLabel:(UILabel*)label withDuration:(NSTimeInterval)duration toRight:(BOOL)toRight
{
    [label setText:@""];
    
    NSTimeInterval delay = duration / newText.length;
    
    if (toRight) {
        for (int i=0; i<newText.length; i++)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [label setText:[NSString stringWithFormat:@"%@%C", label.text, [newText characterAtIndex:i]]];
                               label.alpha = ((CGFloat)i)/(newText.length-1);
                           });
            
            [NSThread sleepForTimeInterval:delay];
        }
    } else {
        if (newText.length > 0) {
            for (int i=(newText.length-1) ; i >= 0; i--)
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [label setText:[NSString stringWithFormat:@"%C%@", [newText characterAtIndex:i], label.text]];
                                   label.alpha = 1-((CGFloat)i)/(newText.length-1);
                               });
                
                [NSThread sleepForTimeInterval:delay];
            }
        }
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateScrollViewWithOffset:scrollView.contentOffset.y];
    [self updateBackgroundWithOffset:scrollView.contentOffset.y];
    [self updateLabelNameWithOffset:scrollView.contentOffset.y];
    [self updateImageProfileWithOffset:scrollView.contentOffset.y];
    [self updateButtonTopWithOffset:scrollView.contentOffset.y];
    
    
    if (scrollView.contentOffset.y > 141 && !isShort) {
        [self setProfileShort:YES];
    }
    if (scrollView.contentOffset.y < 141 && isShort) {
        [self setProfileShort:NO];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	// This enables the user to scroll down the navbar by tapping the status bar.
	[self showNavbar];
	
	return YES;
}

- (void)updateButtonTopWithOffset:(CGFloat)offsetY
{
    if ( offsetY < 10 && self.buttonCall.layer.opacity == 0.f) {
        
        self.buttonCall.layer.opacity =  0.01f;
        NSBKeyframeAnimation *animation = [NSBKeyframeAnimation animationWithKeyPath:@"transform.translation.x"
                                                                            duration:0.7
                                                                          startValue:100
                                                                            endValue:0
                                                                            function:NSBKeyframeAnimationFunctionEaseOutBack];
        animation.completionBlock = ^(BOOL completed) {
            if (completed) {
                self.buttonCall.layer.opacity = 1.f;
            }
        };
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.buttonCall.layer addAnimation:animation forKey:@"position.x"];
        
        
        CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOnColor.duration = 0.7;
        animateOnColor.fromValue = @0;
        animateOnColor.toValue = @1;
        animateOnColor.removedOnCompletion = NO;
        animateOnColor.fillMode = kCAFillModeForwards;
        [self.buttonCall.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
        
    }
    if ( offsetY > 10  && self.buttonCall.layer.opacity == 1.f) {
        
        self.buttonCall.layer.opacity =  0.99f;
        
        NSBKeyframeAnimation *animation = [NSBKeyframeAnimation animationWithKeyPath:@"transform.translation.x"
                                                                            duration:0.7
                                                                          startValue:0
                                                                            endValue:100
                                                                            function:NSBKeyframeAnimationFunctionEaseInBack];
        animation.completionBlock = ^(BOOL completed) {
            if (completed) {
                self.buttonCall.layer.opacity = 0.f;
            }
        };
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.buttonCall.layer addAnimation:animation forKey:@"position.x"];
        
        
        CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOnColor.duration = 0.7;
        animateOnColor.fromValue = @1;
        animateOnColor.toValue = @0;
        animateOnColor.removedOnCompletion = NO;
        animateOnColor.fillMode = kCAFillModeForwards;
        [self.buttonCall.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
    }
    if ( offsetY < 55 && self.buttonMail.layer.opacity == 0.f) {
        
        self.buttonMail.layer.opacity =  0.01f;
        NSBKeyframeAnimation *animation = [NSBKeyframeAnimation animationWithKeyPath:@"transform.translation.x"
                                                                            duration:0.7
                                                                          startValue:100
                                                                            endValue:0
                                                                            function:NSBKeyframeAnimationFunctionEaseOutBack];
        animation.completionBlock = ^(BOOL completed) {
            if (completed) {
                self.buttonMail.layer.opacity = 1.f;
            }
        };
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.buttonMail.layer addAnimation:animation forKey:@"position.x"];
        
        
        CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOnColor.duration = 0.7;
        animateOnColor.fromValue = @0;
        animateOnColor.toValue = @1;
        animateOnColor.removedOnCompletion = NO;
        animateOnColor.fillMode = kCAFillModeForwards;
        [self.buttonMail.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
    }
    if (offsetY > 55 && self.buttonMail.layer.opacity == 1.f) {
        
        self.buttonMail.layer.opacity =  0.99f;
        
        NSBKeyframeAnimation *animation = [NSBKeyframeAnimation animationWithKeyPath:@"transform.translation.x"
                                                                            duration:0.7
                                                                          startValue:0
                                                                            endValue:100
                                                                            function:NSBKeyframeAnimationFunctionEaseInBack];
        animation.completionBlock = ^(BOOL completed) {
            if (completed) {
                self.buttonMail.layer.opacity = 0.f;
            }
        };
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.buttonMail.layer addAnimation:animation forKey:@"position.x"];
        
        
        CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOnColor.duration = 0.7;
        animateOnColor.fromValue = @1;
        animateOnColor.toValue = @0;
        animateOnColor.removedOnCompletion = NO;
        animateOnColor.fillMode = kCAFillModeForwards;
        [self.buttonMail.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
    }

}

- (void)updateScrollViewWithOffset:(CGFloat)offsetY
{
    if (offsetY < 0) {
        self.contraintTopViewTop.constant = offsetY;
        self.constraintBetweenView.constant = -offsetY;
    }
    if (offsetY > 0 && offsetY < 141) {
        self.contraintTopViewTop.constant = 0;
        self.constraintBetweenView.constant = 0;
    }
    if (offsetY > 141) {
        self.contraintTopViewTop.constant = offsetY -141;
        self.constraintBetweenView.constant = - (offsetY -141);
    }
}

- (void)updateBackgroundWithOffset:(CGFloat)offsetY
{
    if (offsetY < 0) {
        self.constraintHeightBackground.constant = 227;
        self.constraintTopBackground.constant = offsetY;
    }
    if (offsetY > 0 && offsetY < 141) {
        self.constraintHeightBackground.constant = 227 - offsetY*(3./4);
        self.constraintTopBackground.constant = offsetY*(3./4);
    }
    if (offsetY > 141) {
        self.constraintHeightBackground.constant = 227 - 141*(3./4);
        self.constraintTopBackground.constant = offsetY - 141*(1./4);
    }
}

- (void)updateLabelNameWithOffset:(CGFloat)offsetY
{
    if (offsetY < 16 && self.viewNameLocalisation.alpha != 1) {
        self.viewNameLocalisation.alpha = 1;
    }
    if (offsetY > 0 && offsetY < 72) {
        CGFloat percent = 1 - ((offsetY - 16)/(72-16));
        self.viewNameLocalisation.alpha = percent;
    }
    if (offsetY > 72 && self.viewNameLocalisation.alpha != 0) {
        self.viewNameLocalisation.alpha = 0;
    }
}

- (void)updateImageProfileWithOffset:(CGFloat)offsetY
{
    if (offsetY < 16 && self.constraintTopImage.constant != 16) {
        self.constraintTopImage.constant = 16;
    }
    if (offsetY > 15 && offsetY < 142) {
        self.constraintTopImage.constant = offsetY+1;
    }
    if (offsetY > 142 && self.constraintTopImage.constant != 142) {
        self.constraintTopImage.constant = 142;
    }
}

- (void) setProfileShort:(BOOL)on
{
    
    isShort = on;
    NSString *translationKeyX = @"transform.translation.x";
    NSString *translationKeyY = @"transform.translation.y";
    
    self.imageViewProfileShort.layer.transform = CATransform3DMakeTranslation (0, (on ? 100 : 0), 0);
    self.viewProjectShort.layer.transform = CATransform3DMakeTranslation( (on ? 160 : 0), 0, 0);
    self.viewTaskShort.layer.transform = CATransform3DMakeTranslation( (on ? 160 : 0), 0, 0);
    self.viewNoteShort.layer.transform = CATransform3DMakeTranslation( (on ? 160 : 0), 0, 0);
    self.viewNameShort.layer.transform = CATransform3DMakeTranslation( (on ? -160 : 0), 0, 0);
    
    CABasicAnimation *animateTranslationProfile = [CABasicAnimation animationWithKeyPath:translationKeyY];
    animateTranslationProfile.duration = 0.3;
    animateTranslationProfile.fromValue = on ? @100 : @0;
    animateTranslationProfile.toValue = on ? @0 : @100;
    animateTranslationProfile.removedOnCompletion = NO;
    animateTranslationProfile.fillMode = kCAFillModeForwards;
    [self.imageViewProfileShort.layer addAnimation:animateTranslationProfile forKey:@"animateTranslation"];
    
    CABasicAnimation *animateTranslationProject = [CABasicAnimation animationWithKeyPath:translationKeyX];
    animateTranslationProject.duration = 0.3;
    animateTranslationProject.fromValue = on ? @160 : @0;
    animateTranslationProject.toValue = on ? @0 : @160;
    animateTranslationProject.removedOnCompletion = NO;
    animateTranslationProject.fillMode = kCAFillModeForwards;
    [self.viewProjectShort.layer addAnimation:animateTranslationProject forKey:@"animateTranslation"];
    
    CABasicAnimation *animateTranslationTask = [CABasicAnimation animationWithKeyPath:translationKeyX];
    animateTranslationTask.duration = 0.3;
    [animateTranslationTask setBeginTime:CACurrentMediaTime()+0.05];
    animateTranslationTask.fromValue = on ? @160 : @0;
    animateTranslationTask.toValue = on ? @0 : @160;
    animateTranslationTask.removedOnCompletion = NO;
    animateTranslationTask.fillMode = kCAFillModeForwards;
    [self.viewTaskShort.layer addAnimation:animateTranslationTask forKey:@"animateTranslation"];
    
    CABasicAnimation *animateTranslationNote = [CABasicAnimation animationWithKeyPath:translationKeyX];
    animateTranslationNote.duration = 0.3;
    [animateTranslationNote setBeginTime:CACurrentMediaTime()+0.1];
    animateTranslationNote.fromValue = on ? @160 : @0;
    animateTranslationNote.toValue = on ? @0 : @160;
    animateTranslationNote.removedOnCompletion = NO;
    animateTranslationNote.fillMode = kCAFillModeForwards;
    [self.viewNoteShort.layer addAnimation:animateTranslationNote forKey:@"animateTranslation"];
    
    CABasicAnimation *animateTranslationName = [CABasicAnimation animationWithKeyPath:translationKeyX];
    animateTranslationName.duration = 0.3;
    animateTranslationName.fromValue = on ? @(-160) : @0;
    animateTranslationName.toValue = on ? @0 : @(-160);
    animateTranslationName.removedOnCompletion = NO;
    animateTranslationName.fillMode = kCAFillModeForwards;
    [self.viewNameShort.layer addAnimation:animateTranslationName forKey:@"animateTranslation"];
    
    CABasicAnimation *animateOffColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animateOffColor.duration = 0.3;
    animateOffColor.fromValue = on ? @1 : @0;
    animateOffColor.toValue = on ? @0 : @1;
    animateOffColor.removedOnCompletion = NO;
    animateOffColor.fillMode = kCAFillModeForwards;
    [self.viewBackgroundLong.layer addAnimation:animateOffColor forKey:@"animateOpacity"];
    
    CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animateOnColor.duration = 0.3;
    animateOnColor.fromValue = on ? @0 : @1;
    animateOnColor.toValue = on ? @1 : @0;
    animateOnColor.removedOnCompletion = NO;
    animateOnColor.fillMode = kCAFillModeForwards;
    [self.viewBackgroundShort.layer addAnimation:animateOnColor forKey:@"animateOpacity"];
    
    [CATransaction commit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AnotherPopoverSegue"])
    {
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        anotherPopoverController = [popoverSegue popoverControllerWithSender:sender
                                                    permittedArrowDirections:WYPopoverArrowDirectionDown
                                                                    animated:YES
                                                                     options:WYPopoverAnimationOptionFadeWithScale];
        anotherPopoverController.theme = [WYPopoverTheme themeForIOS7];
        anotherPopoverController.delegate = self;
        self.preferredContentSize = CGSizeMake(220, 261);
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return authorizedOrientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return authorizedOrientation;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        if (self.fullScreenView == nil) {
            isLandscape = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            
//            [self.ganttView removeFromSuperview];
            [self.fullScreenView removeFromSuperview];
            self.fullScreenView = nil;
            
            self.fullScreenView = [[UIView alloc] init];
            self.fullScreenView.backgroundColor = [UIColor clearColor];
            
            [self.fullScreenView addSubview:self.ganttView];
            self.fullScreenView.transform = CGAffineTransformMakeRotation((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ? -M_PI/2 : M_PI/2);
            self.fullScreenView.frame = [UIScreen mainScreen].bounds;
            self.ganttView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            
            self.ganttView.layer.cornerRadius = 0;
            
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.fullScreenView];
        }
        
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        isLandscape = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.ganttView removeFromSuperview];
        [self.fullScreenView removeFromSuperview];
        self.fullScreenView = nil;
        self.ganttView.frame = self.viewContainerGanttView.bounds;
        self.ganttView.layer.cornerRadius = 10;
        [self.viewContainerGanttView addSubview:self.ganttView];
    }
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        if (self.fullScreenView != nil) {
            isLandscape = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            
//            [self.ganttView removeFromSuperview];
            [self.fullScreenView removeFromSuperview];
            self.fullScreenView = nil;
            
            self.fullScreenView = [[UIView alloc] init];
            self.fullScreenView.backgroundColor = [UIColor clearColor];
            
            [self.fullScreenView addSubview:self.ganttView];
            self.fullScreenView.transform = CGAffineTransformMakeRotation((currentOrientation == UIInterfaceOrientationLandscapeLeft) ? -M_PI/2 : M_PI/2);
            self.fullScreenView.frame = [UIScreen mainScreen].bounds;
            self.ganttView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            self.ganttView.layer.cornerRadius = 0;
            
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.fullScreenView];
        }
    }
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - Orientation Change Action
- (void)updateScreenInfo
{
    NSLog(@"%@",[NSString stringWithFormat:@"Width: %.0f - Height : %.0f", self.view.frame.size.width, self.view.frame.size.height]);
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == anotherPopoverController)
    {
        anotherPopoverController.delegate = nil;
        anotherPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
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

#pragma Funny thing

- (void)drawBezierAnimate:(BOOL)animate
{
    UIBezierPath *bezierPath = [self bezierPath];
    
    CAShapeLayer *bezier = [[CAShapeLayer alloc] init];
    
    bezier.path          = bezierPath.CGPath;
    bezier.strokeColor   = [UIColor whiteColor].CGColor;
    bezier.fillColor     = [UIColor clearColor].CGColor;
    bezier.lineWidth     = 5.0;
    bezier.strokeStart   = 0.0;
    bezier.strokeEnd     = 1.0;
//    [self.imageViewProfile.layer addSublayer:bezier];
//    
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 1.0 / 500.0;
////    transform = CATransform3DScale(transform ,0.5f, 0.5f, 1.f);
////    CGAffineTransform transform = CGAffineTransformMakeScale(0.5f, 0.5f);
//    self.imageViewProfile.layer.transform = transform;
//    
//    if (animate)
//    {
//        CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        animateStrokeEnd.duration  = 2.0;
//        animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
//        animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
//        [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
//        
//        CABasicAnimation *animateAlphaB = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        animateAlphaB.duration  = 2.0;
//        animateAlphaB.fromValue = [NSNumber numberWithFloat:1.f];
//        animateAlphaB.toValue   = [NSNumber numberWithFloat:0.5f];
//        [bezier addAnimation:animateAlphaB forKey:@"opacityAnimation"];
//        
//        CABasicAnimation *animateAlpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        animateAlpha.duration  = 2.0;
//        animateAlpha.fromValue = [NSNumber numberWithFloat:0.5f];
//        animateAlpha.toValue   = [NSNumber numberWithFloat:1.f];
//        [self.imageViewProfile.layer addAnimation:animateAlpha forKey:@"opacityAnimation"];
//                
////        [UIView animateWithDuration:1.f animations:^{
////            self.imageViewProfile.layer.transform = CATransform3DIdentity;
////        }];
//        
//        CABasicAnimation* animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
//        animationRotation.duration = 2.0;
//        animationRotation.fromValue = @(0);
//        animationRotation.toValue = @(2 * M_PI);
//        [self.imageViewProfile.layer addAnimation:animationRotation forKey:@"rotation"];
//        
//        [CATransaction commit];
//    }
}

- (UIBezierPath *)bezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageViewProfile.bounds cornerRadius:self.imageViewProfile.bounds.size.width/2];
    
    return path;
}

@end
