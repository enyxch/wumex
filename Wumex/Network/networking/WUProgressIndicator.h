//
//  WUProgressIndicator.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 7/4/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

extern NSString * const kWUProgressIndicatorMessageUploadingPicture;
extern NSString * const kWUProgressIndicatorMessageUploadingFile;
extern NSString * const kWUProgressIndicatorMessageDownloadingFile;
extern NSString * const kWUProgressIndicatorMessageUploadingData;
extern NSString * const kWUProfressIndicatorMessageUpdatingProfile;

@interface WUProgressIndicator : NSObject

- (void)showDownloadingDataSpinnerForView:(UIView *)view;

- (void)showSpinnerForView:(UIView *)view mode:(MBProgressHUDMode)mode message:(NSString *)message;

- (void)showSpinnerCompletedForView:(UIView *)view withText:(NSString*)message forDelay:(NSTimeInterval)delay;

- (void)showSpinnerForView:(UIView *)view;

- (void)hideSpinnerForView:(UIView *)view;

- (void)hideSpinnerForView:(UIView *)view afterDelay:(NSTimeInterval)delay;

- (void)setSpinnerMode:(MBProgressHUDMode)mode;

- (void)setSpinnerMessage:(NSString *)message;

- (void)setSpinnerDetailsMessage:(NSString *)message;

- (void)setSpinnerProgress:(float)progress;

- (void)setSpinnerCustomView:(UIView *)view;


+ (WUProgressIndicator *)defaultProgressIndicator;

@end