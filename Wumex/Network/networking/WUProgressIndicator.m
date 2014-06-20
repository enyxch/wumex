//
//  WUProgressIndicator.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/4/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUProgressIndicator.h"

NSString * const kWUProgressIndicatorMessageUploadingPicture = @"Uploading picture";
NSString * const kWUProgressIndicatorMessageUploadingFile = @"Uploading file";
NSString * const kWUProgressIndicatorMessageDownloadingFile = @"Downloading file";
NSString * const kWUProgressIndicatorMessageUploadingData = @"Uploading data";
NSString * const kWUProgressIndicatorMessageDownloadingData = @"Downloading data";
NSString * const kWUProfressIndicatorMessageUpdatingProfile = @"Updating profile";

@interface WUProgressIndicator()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation WUProgressIndicator

- (void)showDownloadingDataSpinnerForView:(UIView *)view
{
    [self showSpinnerForView:view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Downloading data", nil)];
}

- (void)showSpinnerForView:(UIView *)view mode:(MBProgressHUDMode)mode message:(NSString *)message
{
    [self showSpinnerForView:view];
    [self setSpinnerMode:mode];
    [self setSpinnerMessage:message];
}

- (void)showSpinnerCompletedForView:(UIView *)view withText:(NSString*)message forDelay:(NSTimeInterval)delay
{
    [self.hud hide:YES];
    
    self.hud = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:self.hud];
	
	self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	self.hud.mode = MBProgressHUDModeCustomView;
	
	self.hud.labelText = message;
	
	[self.hud show:YES];
	[self.hud hide:YES afterDelay:delay];
}

- (void)showSpinnerForView:(UIView *)view
{
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)hideSpinnerForView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideAllHUDsForView:view animated:YES];
    });

    self.hud = nil;
}

- (void)hideSpinnerForView:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(hideSpinnerForView:) withObject:view afterDelay:delay];
    self.hud = nil;
}

- (void)setSpinnerMessage:(NSString *)message
{
    if (self.hud != nil) {
        self.hud.labelText = message;
    }
}

- (void)setSpinnerDetailsMessage:(NSString *)message
{
    if (self.hud != nil) {
        [self.hud setDetailsLabelText:message];
    }
}

- (void)setSpinnerMode:(MBProgressHUDMode)mode
{
    if (self.hud != nil) {
        [self.hud setMode:mode];
    }
}

- (void)setSpinnerProgress:(float)progress
{
    if (self.hud != nil) {
        self.hud.progress = progress;
    }
}

- (void)setSpinnerCustomView:(UIView *)view
{
    if (self.hud != nil) {
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = view;
    }
}

+ (WUProgressIndicator *)defaultProgressIndicator
{
    static WUProgressIndicator *defaultProgressIndicator;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultProgressIndicator = [WUProgressIndicator new];
    });

    return defaultProgressIndicator;
}

@end
