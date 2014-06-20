//
//  UIHelpers.m
//  Global_Jury
//
//  Created by Dawid Pośliński on 25.06.2013.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "UIHelper.h"

NSString * const CHAT_COLOR     = @"#c1d72e";
NSString * const NOTE_COLOR     = @"#0069b4";
NSString * const TASK_COLOR     = @"#f18217";
NSString * const PROJECT_COLOR  = @"#00b863";
NSString * const MORE_COLOR     = @"#11a0db";
NSString * const TEXT_COLOR     = @"#565657";
NSString * const RED_COLOR      = @"#fe4b48";

@implementation UIHelper

+ (Boolean)iPhone5 {
	
	return ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
}

+ (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)image {
	
	UIImage *customImage = [UIImage imageNamed:image];
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, customImage.size.width, customImage.size.height)];
	customView.backgroundColor = [UIColor colorWithPatternImage:customImage];
	
	return [[UIBarButtonItem alloc] initWithCustomView:customView];
}

+ (UIBarButtonItem *)flatBarButtonItemWithImageNamed:(NSString *)image target:(id)target action:(SEL)action
{
	UIImage *customImage = [UIImage imageNamed:image];
	UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, customImage.size.width, customImage.size.height)];
	customButton.backgroundColor = [UIColor colorWithPatternImage:customImage];
	
    [customButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
	return [[UIBarButtonItem alloc] initWithCustomView:customButton];
}

+ (UIEdgeInsets)defaultInsets {
	
	return UIEdgeInsetsMake(4, 4, 4, 4);
}

+ (UIColor *)colorFromHex:(NSString *)hex {
	
	NSInteger red, green, blue;
	sscanf([hex UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
	
	return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+ (UIImage *)cropImage:(UIImage *)image toCropRect:(CGRect)cropRect {
	
    float scale = image.scale;
	
//    //NSLog(@"cropImage image scale: %f", scale);

	if (
			[image imageOrientation] == UIImageOrientationLeft || [image imageOrientation] == UIImageOrientationRight ||
			[image imageOrientation] == UIImageOrientationLeftMirrored || [image imageOrientation] == UIImageOrientationRightMirrored
		) {
		
		cropRect = CGRectMake(cropRect.origin.y, cropRect.origin.x, cropRect.size.height, cropRect.size.width);
	}
    
    cropRect = CGRectMake(cropRect.origin.x * scale, cropRect.origin.y * scale, cropRect.size.width * scale, cropRect.size.height * scale);
	
	CGImageRef selectedImage = CGImageCreateWithImageInRect([image CGImage],cropRect);
	
	UIImage *img = [UIImage
					imageWithCGImage:selectedImage
					scale:[image scale]
					orientation:[image imageOrientation]];
	
    CGImageRelease(selectedImage);
	
	return img;
}

+ (UIImage *)cropImage:(UIImage *)image toSize:(CGSize)destinationSize {

	CGSize size = [image size];
	CGRect rect = CGRectMake(
								 (int)((size.width/2)-(destinationSize.width/2)),
								 (int)((size.height/2)-(destinationSize.height/2)),
								 destinationSize.width,
								 destinationSize.height
							 );
	
    UIGraphicsBeginImageContext(size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
	return img;
}

+ (UIImage *)reduceImage:(UIImage *)image toMaxSize:(int)size {
	
	if ( image.size.width > size || image.size.height > size)  {
		float scale = (float)size / MAX(image.size.width, image.size.height);
		CGSize scaledSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
		
		return [UIHelper imageWithImage:image convertToSize:scaledSize];
	}
	
	return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (UIImage *)getResizeAndCropImage:(UIImage *)image forMaskSize:(CGSize)maskSize{
    
    
    float maskWidth = maskSize.width;
    float maskHeight = maskSize.height;
    
    if ([UIScreen mainScreen].scale == 2.f) {
        maskWidth = maskWidth*2;
        maskHeight = maskHeight*2;
    }
    
    CGSize imageSize = [image size];
    
    float cropScaleX = imageSize.width / maskWidth;
    float cropScaleY = imageSize.height / maskHeight;
    
    float minCropScale  = MIN(cropScaleX, cropScaleY);
    float cropWidth		= maskWidth * minCropScale;
    float cropHeight	= maskHeight * minCropScale;
    float cropX			= (imageSize.width / 2) - (cropWidth / 2);
    float cropY			= (imageSize.height / 2) - (cropHeight / 2);
    
    UIImage *croppedPhoto = [UIHelper cropImage:image toCropRect:CGRectMake(cropX, cropY, cropWidth, cropHeight)];
    UIImage *resizedPhoto = [UIHelper imageWithImage:croppedPhoto convertToSize:CGSizeMake(maskWidth, maskHeight)];
    return resizedPhoto;
}

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
    CGImageRef maskRef = maskImage.CGImage;
	
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, YES);
	
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
	
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
	
    return maskedImage;
}

+ (UIImage *)scaleImageForUpload:(UIImage *)image
{
    const NSInteger kWUScaledLongerSide = 800;

    float shortToLongSizeRatio;
    CGSize scaledDownSize;
    if (image.size.width > image.size.height)
    {
        shortToLongSizeRatio = (float)image.size.height/(float)image.size.width;

        scaledDownSize.width = kWUScaledLongerSide;
        scaledDownSize.height = (int)(shortToLongSizeRatio * kWUScaledLongerSide);
    }
    else
    {
        shortToLongSizeRatio = (float)image.size.width/(float)image.size.height;

        scaledDownSize.height = kWUScaledLongerSide;
        scaledDownSize.width = (int)(shortToLongSizeRatio * kWUScaledLongerSide);
    }

    return [UIHelper imageWithImage:image convertToSize:scaledDownSize];
}

+ (NSDateFormatter *) localizedDateFormatterWithDateStyle:(NSDateFormatterStyle)dateSyle andTimeSyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:timeStyle];
    [dateFormatter setDateStyle:dateSyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[NSLocale preferredLanguages][0]]];
    return dateFormatter;
}

+ (NSArray*)loadingImagesForSize:(CGSize)size
{
    NSMutableArray* animationImages = [NSMutableArray array];
    if (size.height == 0 || size.width == 0) {
        size = CGSizeMake(100, 100);
    }
    for (int i = 0 ; i < 8; i++) {
        [animationImages addObject:[UIHelper getResizeAndCropImage:[UIImage imageNamed:[NSString stringWithFormat:@"loading_%d", i]] forMaskSize:size]];
    }
    return animationImages;
}

+ (UIView*)infoRightBubbleViewForText:(NSString*)text
{
    UIView *view = [[UIView alloc] init];
    
    UIFont *fontReceive = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize sizeText = [text sizeWithFont:fontReceive constrainedToSize:CGSizeMake(260, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, sizeText.width, sizeText.height)];
    labelText.numberOfLines = 0;
    labelText.lineBreakMode = NSLineBreakByWordWrapping;
    labelText.text = text;
    labelText.font = fontReceive;
    labelText.textColor = [UIColor whiteColor];
    labelText.backgroundColor = [UIColor clearColor];
    
    UIImageView *bubble = [[UIImageView alloc] init];
    bubble.image = [[UIImage imageNamed:@"categoriedetailvote_tooltip_right"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    
    bubble.frame = CGRectMake(0, 0, sizeText.width + 18, sizeText.height + 22);
    
    view.frame = bubble.frame;
    [view addSubview:bubble];
    [view addSubview:labelText];
    
    return  view;
}

+ (UIView*)infoMiddleBubbleViewForText:(NSString*)text
{
    UIView *view = [[UIView alloc] init];
    
    UIFont *fontReceive = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize sizeText = [text sizeWithFont:fontReceive constrainedToSize:CGSizeMake(260, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, sizeText.width, sizeText.height)];
    labelText.numberOfLines = 0;
    labelText.lineBreakMode = NSLineBreakByWordWrapping;
    labelText.text = text;
    labelText.font = fontReceive;
    labelText.textColor = [UIColor whiteColor];
    labelText.backgroundColor = [UIColor clearColor];
    
    UIImageView *bubble0 = [[UIImageView alloc] init];
    bubble0.image = [[UIImage imageNamed:@"categoriedetailvote_tooltip_middle"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    
    bubble0.frame = CGRectMake(0, 0, (sizeText.width)/2 + 18, (sizeText.height)/2 + 22);
    
    UIGraphicsBeginImageContextWithOptions(bubble0.bounds.size, bubble0.opaque, 0.0);
    [bubble0.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView *bubble = [[UIImageView alloc] init];
    bubble.image = [img stretchableImageWithLeftCapWidth:bubble0.frame.size.width-10 topCapHeight:6];
    
    bubble.frame = CGRectMake(0, 0, (sizeText.width + 18), (sizeText.height + 22));
    
    view.frame = bubble.frame;
    [view addSubview:bubble];
    [view addSubview:labelText];
    
    return  view;
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)imageBlackAndWhite:(UIImage *)image
{
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", @0.0f, @"inputContrast", @1.1f, @"inputSaturation", @0.0f, nil].outputImage;
    CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", @0.7f, nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

+ (NSString*)dateToString:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmpnts= [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    NSDateComponents *cmpntsToday= [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    
    if ([cmpnts isEqual:cmpntsToday]) {
        return NSLocalizedString(@"Today", nil);
    }
    cmpntsToday.day -= 1;
    if ([cmpnts isEqual:cmpntsToday]) {
        return NSLocalizedString(@"Yesterday", nil);
    }
    cmpntsToday.day += 2;
    if ([cmpnts isEqual:cmpntsToday]) {
        return NSLocalizedString(@"Tomorrow", nil);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[NSLocale preferredLanguages][0]]];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)timeIntervalToString:(NSNumber*)estimatedTimeNum
{
    CGFloat estimatedTime = [estimatedTimeNum floatValue];
    int dayNumber = estimatedTime/(24*60*60);
    estimatedTime -= ((int)dayNumber)*24*60*60;
    int hourNumber = estimatedTime/(60*60*3);
    NSString* stringEstimatedTime = @"";
    if (dayNumber > 0) {
        stringEstimatedTime  = [NSString stringWithFormat:NSLocalizedString(@"%dd", @"%d for the number - d for day"), dayNumber];
    }
    return [NSString stringWithFormat:NSLocalizedString(@"%@ %dh", @"%d for the number - h for hours"), stringEstimatedTime, hourNumber];
}

@end








