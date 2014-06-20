//
//  PopoverViewController.m
//  ChatHeads
//
//  Created by Nicolas Bonnet on 12.05.14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController ()

@end

@implementation PopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.preferredContentSize = CGSizeMake(160, 64);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button1tapped:(id)sender
{
    self.imageView.image = [UIImage imageNamed:@"success"];
    self.imageView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    
    [UIView animateWithDuration:0.2f delay:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelTitle.text = @"YES";
        self.imageView.alpha = 1.f;
        self.imageView.transform = CGAffineTransformIdentity;
        self.button1.alpha = 0.f;
        self.button2.alpha = 0.f;
    } completion:^(BOOL finished) {
        //[imageView removeFromSuperview];
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(close) userInfo:nil repeats:NO];
    }];
}

- (IBAction)button2tapped:(id)sender
{
    self.imageView.image = [UIImage imageNamed:@"error"];
    self.imageView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    
    [UIView animateWithDuration:0.2f delay:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelTitle.text = @"NO";
        self.imageView.alpha = 1.f;
        self.imageView.transform = CGAffineTransformIdentity;
        self.button1.alpha = 0.f;
        self.button2.alpha = 0.f;
    } completion:^(BOOL finished) {
        //[imageView removeFromSuperview];
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(close) userInfo:nil repeats:NO];
    }];
}

- (void)close
{
    if (self.blockClose != nil) {
        self.blockClose();
    }
}

@end
