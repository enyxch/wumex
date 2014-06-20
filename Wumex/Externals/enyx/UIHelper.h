//
//  UIHelpers.h
//  Global_Jury
//
//  Created by Dawid Pośliński on 25.06.2013.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

extern NSString * const CHAT_COLOR;
extern NSString * const NOTE_COLOR;
extern NSString * const TASK_COLOR;
extern NSString * const PROJECT_COLOR;
extern NSString * const MORE_COLOR;
extern NSString * const TEXT_COLOR;
extern NSString * const RED_COLOR;

#import <Foundation/Foundation.h>

@interface UIHelper : NSObject

+ (Boolean)iPhone5;

+ (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)image;
+ (UIBarButtonItem *)flatBarButtonItemWithImageNamed:(NSString *)image target:(id)target action:(SEL)action;

+ (UIColor *)colorFromHex:(NSString *)hex;

+ (UIEdgeInsets)defaultInsets;

// image helpers
+ (UIImage *)cropImage:(UIImage *)image toSize:(CGSize)destinationSize;
+ (UIImage *)reduceImage:(UIImage *)image toMaxSize:(int)size;
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (UIImage *)getResizeAndCropImage:(UIImage *)image forMaskSize:(CGSize)maskSize;

+ (UIImage *)cropImage:(UIImage *)image toCropRect:(CGRect)cropRect;

+ (UIImage *)scaleImageForUpload:(UIImage *)image;

+ (NSDateFormatter *) localizedDateFormatterWithDateStyle:(NSDateFormatterStyle)dateSyle andTimeSyle:(NSDateFormatterStyle)timeStyle;

+ (NSArray*)loadingImagesForSize:(CGSize)size;

+ (UIView*)infoRightBubbleViewForText:(NSString*)text;
+ (UIView*)infoMiddleBubbleViewForText:(NSString*)text;
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)imageBlackAndWhite:(UIImage *)image;

+ (NSString*)dateToString:(NSDate*)date;
+ (NSString*)timeIntervalToString:(NSNumber*)estimatedTime;

@end
