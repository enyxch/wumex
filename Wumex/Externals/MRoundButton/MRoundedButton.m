//
//  MRoundButton.m
//
//  Copyright (c) 2014 Michael WU. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MRoundedButton.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const MRoundedButtonMaxValue = CGFLOAT_MAX;

#define M_MAX_CORNER_RADIUS MIN(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0)
#define M_MAX_BORDER_WIDTH  M_MAX_CORNER_RADIUS
#define M_MAGICAL_VALUE     0.29

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

static CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets)
{
    return CGRectMake(CGRectGetMinX(rect) + insets.left,
                      CGRectGetMinY(rect) + insets.top,
                      CGRectGetWidth(rect) - insets.left - insets.right,
                      CGRectGetHeight(rect) - insets.top - insets.bottom);
}

@interface MRTextLayer : UIView
@property (nonatomic, strong)   UILabel *textLabel;
@end

@implementation MRTextLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.1;
        self.textLabel.numberOfLines = 1;
        self.layer.mask = self.textLabel.layer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

@end

@interface MRImageLayer : UIView
@property (nonatomic, strong)   UIImageView *imageView;
@end

@implementation MRImageLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor clearColor];
        self.layer.mask = self.imageView.layer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end

@interface MRoundedButton ()
@property (nonatomic, strong)                   UIColor                 *backgroundColorCache;
@property (assign, getter = isTrackingInside)   BOOL                    trackingInside;
@property (nonatomic, strong)                   UIView                  *foregroundView;
@property (nonatomic, strong)                   MRTextLayer             *textLayer;
@property (nonatomic, strong)                   MRTextLayer             *detailTextLayer;
@property (nonatomic, strong)                   MRImageLayer            *imageLayer;
@property (nonatomic, strong)                   MRImageLayer            *imageSelectedLayer;

@end

@implementation MRoundedButton

- (instancetype)initWithFrame:(CGRect)frame
                  buttonStyle:(MRoundedButtonStyle)style
           appearanceIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.masksToBounds = YES;
        
        _mr_buttonStyle = style;
        _mr_buttonHighlighted = NO;
        _contentColor = self.tintColor;
        _foregroundColor = [UIColor whiteColor];
        _restoreHighlightState = YES;
        _trackingInside = NO;
        _cornerRadius = 0.0;
        _borderWidth = 0.0;
        _contentEdgeInsets = UIEdgeInsetsZero;
        
        self.foregroundView = [[UIView alloc] initWithFrame:CGRectNull];
        self.foregroundView.backgroundColor = self.foregroundColor;
        self.foregroundView.layer.masksToBounds = YES;
        [self addSubview:self.foregroundView];
        
        self.textLayer = [[MRTextLayer alloc] initWithFrame:CGRectNull];
        self.textLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.textLayer aboveSubview:self.foregroundView];
        
        self.detailTextLayer = [[MRTextLayer alloc] initWithFrame:CGRectNull];
        self.detailTextLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.detailTextLayer aboveSubview:self.foregroundView];
        
        self.imageLayer = [[MRImageLayer alloc] initWithFrame:CGRectNull];
        self.imageLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.imageLayer aboveSubview:self.foregroundView];
        
        self.imageSelectedLayer = [[MRImageLayer alloc] initWithFrame:CGRectNull];
        self.imageSelectedLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.imageSelectedLayer aboveSubview:self.foregroundView];
        self.imageSelectedLayer.alpha = 0.f;
        self.imageSelectedLayer.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        [self applyAppearanceForIdentifier:identifier];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(MRoundedButtonStyle)style
{
    return [[MRoundedButton alloc] initWithFrame:frame buttonStyle:style appearanceIdentifier:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [[MRoundedButton alloc] initWithFrame:frame buttonStyle:MRoundedButtonDefault appearanceIdentifier:nil];
}

+ (instancetype)buttonWithFrame:(CGRect)frame buttonStyle:(MRoundedButtonStyle)style appearanceIdentifier:(NSString *)identifier
{
    return [[MRoundedButton alloc] initWithFrame:frame buttonStyle:style appearanceIdentifier:identifier];
}

- (CGRect)boxingRect
{
    CGRect internalRect = CGRectInset(self.bounds,
                                      self.layer.cornerRadius * M_MAGICAL_VALUE + self.layer.borderWidth,
                                      self.layer.cornerRadius * M_MAGICAL_VALUE + self.layer.borderWidth);
    return CGRectEdgeInset(internalRect, self.contentEdgeInsets);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cornerRadius = self.layer.cornerRadius = MAX(MIN(M_MAX_CORNER_RADIUS, self.cornerRadius), 0);
    CGFloat borderWidth = self.layer.borderWidth = MAX(MIN(M_MAX_BORDER_WIDTH, self.borderWidth), 0);
    
    _borderWidth = borderWidth;
    _cornerRadius = cornerRadius;
    
    CGFloat layoutBorderWidth = borderWidth == 0.0 ? 0.0 : borderWidth - 0.1;
    self.foregroundView.frame = CGRectMake(layoutBorderWidth,
                                           layoutBorderWidth,
                                           CGRectGetWidth(self.bounds) - layoutBorderWidth * 2,
                                           CGRectGetHeight(self.bounds) - layoutBorderWidth * 2);
    self.foregroundView.layer.cornerRadius = cornerRadius - borderWidth;
    
    switch (self.mr_buttonStyle)
    {
        case MRoundedButtonDefault:
        {
            self.imageLayer.frame = CGRectNull;
            self.imageSelectedLayer.frame = CGRectNull;
            self.detailTextLayer.frame = CGRectNull;
            self.textLayer.frame = [self boxingRect];
        }
            break;
            
        case MRoundedButtonSubtitle:
        {
            self.imageLayer.frame = CGRectNull;
            self.imageSelectedLayer.frame = CGRectNull;
            CGRect boxRect = [self boxingRect];
            self.textLayer.frame = CGRectMake(boxRect.origin.x,
                                              boxRect.origin.y,
                                              CGRectGetWidth(boxRect),
                                              CGRectGetHeight(boxRect) * 0.8);
            self.detailTextLayer.frame = CGRectMake(boxRect.origin.x,
                                                    CGRectGetMaxY(self.textLayer.frame),
                                                    CGRectGetWidth(boxRect),
                                                    CGRectGetHeight(boxRect) * 0.2);
        }
            break;
            
        case MRoundedButtonCentralImage:
        {
            self.textLayer.frame = CGRectNull;
            self.detailTextLayer.frame = CGRectNull;
            self.imageLayer.frame = [self boxingRect];
            self.imageSelectedLayer.frame = [self boxingRect];
        }
            break;
            
        case MRoundedButtonImageWithSubtitle:
        default:
        {
            CGRect boxRect = [self boxingRect];
            self.textLayer.frame = CGRectNull;
            self.imageLayer.frame = CGRectMake(boxRect.origin.x,
                                               boxRect.origin.y,
                                               CGRectGetWidth(boxRect),
                                               CGRectGetHeight(boxRect) * 0.8);
            self.imageSelectedLayer.frame = CGRectMake(boxRect.origin.x,
                                               boxRect.origin.y,
                                               CGRectGetWidth(boxRect),
                                               CGRectGetHeight(boxRect) * 0.8);
            self.detailTextLayer.frame = CGRectMake(boxRect.origin.x,
                                                    CGRectGetMaxY(self.imageLayer.frame),
                                                    CGRectGetWidth(boxRect),
                                                    CGRectGetHeight(boxRect) * 0.2);
        }
            break;
    }
}

#pragma mark - Appearance
- (void)applyAppearanceForIdentifier:(NSString *)identifier
{
    if (![identifier length])
    {
        return;
    }
    
    NSDictionary *appearanceProxy = [MRoundedButtonAppearanceManager appearanceForIdentifier:identifier];
    if (!appearanceProxy)
    {
        return;
    }
    
    [appearanceProxy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

#pragma mark - Setter and getters
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius)
    {
        return;
    }
    
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    if (_borderWidth == borderWidth)
    {
        return;
    }
    
    _borderWidth = borderWidth;
    [self setNeedsLayout];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setContentColor:(UIColor *)contentColor
{
    _contentColor = contentColor;
    self.textLayer.backgroundColor = contentColor;
    self.detailTextLayer.backgroundColor = contentColor;
    self.imageLayer.backgroundColor = contentColor;
    self.imageSelectedLayer.backgroundColor = contentColor;
}

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _foregroundColor = foregroundColor;
    self.foregroundView.backgroundColor = foregroundColor;
}

- (UILabel *)textLabel
{
    return self.textLayer.textLabel;
}

- (UILabel *)detailTextLabel
{
    return self.detailTextLayer.textLabel;
}

- (UIImageView *)imageView
{
    return self.imageLayer.imageView;
}

- (UIImageView *)imageViewSelected
{
    return self.imageSelectedLayer.imageView;
}

#pragma mark - MRoundedButton animation
- (void)fadeAnimation
{
    _mr_buttonHighlighted = !_mr_buttonHighlighted;
    if (self.mr_buttonHighlighted)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.userInteractionEnabled = NO;
            if (self.contentAnimationColor)
            {
                self.textLayer.backgroundColor = self.contentAnimationColor;
                self.detailTextLayer.backgroundColor = self.contentAnimationColor;
                self.imageLayer.backgroundColor = self.contentAnimationColor;
                self.imageSelectedLayer.backgroundColor = self.contentAnimationColor;
                if (!self.restoreHighlightState) {
                    self.imageLayer.alpha = 0.f;
                    self.imageLayer.transform = CGAffineTransformIdentity;
                    self.imageSelectedLayer.alpha = 1.f;
                    self.imageSelectedLayer.transform = CGAffineTransformMakeScale(0.5, 0.5);
                }
            }
            
            if (self.borderAnimationColor &&
                self.foregroundAnimationColor &&
                self.borderAnimationColor == self.foregroundAnimationColor)
            {
                self.backgroundColorCache = self.backgroundColor;
                self.foregroundView.backgroundColor = [UIColor clearColor];
                self.backgroundColor = self.borderAnimationColor;
                return;
            }
            
            if (self.borderAnimationColor)
            {
                self.layer.borderColor = self.borderAnimationColor.CGColor;
            }
            
            if (self.foregroundAnimationColor)
            {
                self.foregroundView.backgroundColor = self.foregroundAnimationColor;
            }
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.userInteractionEnabled = NO;
            self.textLayer.backgroundColor = self.contentColor;
            self.detailTextLayer.backgroundColor = self.contentColor;
            self.imageLayer.backgroundColor = self.contentColor;
            self.imageSelectedLayer.backgroundColor = self.contentColor;
            
            if (!self.restoreHighlightState) {
                self.imageLayer.alpha = 1.f;
                self.imageLayer.transform = CGAffineTransformMakeScale(0.5, 0.5);
                self.imageSelectedLayer.alpha = 0.f;
                self.imageSelectedLayer.transform =  CGAffineTransformIdentity;
            }
            
            if (self.borderAnimationColor &&
                self.foregroundAnimationColor &&
                self.borderAnimationColor == self.foregroundAnimationColor)
            {
                self.foregroundView.backgroundColor = self.foregroundColor;
                self.backgroundColor = self.backgroundColorCache;
                self.backgroundColorCache = nil;
                return;
            }
            
            self.foregroundView.backgroundColor = self.foregroundColor;
            self.layer.borderColor = self.borderColor.CGColor;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - Touchs
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *touchView = [super hitTest:point withEvent:event];
    if ([self pointInside:point withEvent:event])
    {
        return self;
    }
    
    return touchView;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    [self fadeAnimation];
    self.trackingInside = YES;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL wasTrackingInside = self.trackingInside;
    self.trackingInside = self.highlighted = [self isTouchInside];
    
    if (wasTrackingInside && !self.isTrackingInside)
    {
        [self fadeAnimation];
    }
    else if (!wasTrackingInside && self.isTrackingInside)
    {
        [self fadeAnimation];
    }
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.trackingInside = [self isTouchInside];
    if (self.isTrackingInside)
    {
        if (self.restoreHighlightState)
        {
            [self fadeAnimation];
        }
    }
    
    self.trackingInside = NO;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (self.isTrackingInside)
    {
        [self fadeAnimation];
    }
    
    self.trackingInside = NO;
    [super cancelTrackingWithEvent:event];
}

@end

NSString *const kMRoundedButtonCornerRadius                 = @"cornerRadius";
NSString *const kMRoundedButtonBorderWidth                  = @"borderWidth";
NSString *const kMRoundedButtonBorderColor                  = @"borderColor";
NSString *const kMRoundedButtonBorderAnimationColor         = @"borderAnimationColor";
NSString *const kMRoundedButtonContentColor                 = @"contentColor";
NSString *const kMRoundedButtonContentAnimationColor        = @"contentAnimationColor";
NSString *const kMRoundedButtonForegroundColor              = @"foregroundColor";
NSString *const kMRoundedButtonForegroundAnimationColor     = @"foregroundAnimationColor";
NSString *const kMRoundedButtonRestoreHighlightState        = @"restoreHighlightState";

@interface MRoundedButtonAppearanceManager ()
@property (nonatomic, strong)   NSMutableDictionary *appearanceProxys;
@end

@implementation MRoundedButtonAppearanceManager

+ (instancetype)sharedManager
{
    static MRoundedButtonAppearanceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MRoundedButtonAppearanceManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.appearanceProxys = @{}.mutableCopy;
    }
    
    return self;
}

+ (void)registerAppearanceProxy:(NSDictionary *)proxy forIdentifier:(NSString *)identifier
{
    if (!proxy || ![identifier length])
    {
        return;
    }
    
    MRoundedButtonAppearanceManager *manager = [MRoundedButtonAppearanceManager sharedManager];
    (manager.appearanceProxys)[identifier] = proxy;
}

+ (void)unregisterAppearanceProxyIdentier:(NSString *)identifier
{
    if (![identifier length])
    {
        return;
    }
    
    MRoundedButtonAppearanceManager *manager = [MRoundedButtonAppearanceManager sharedManager];
    [manager.appearanceProxys removeObjectForKey:identifier];
}

+ (NSDictionary *)appearanceForIdentifier:(NSString *)identifier
{
    return ([MRoundedButtonAppearanceManager sharedManager].appearanceProxys)[identifier];
}

@end

@implementation MRHollowBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    if (_foregroundColor == foregroundColor)
    {
        return;
    }
    
    _foregroundColor = foregroundColor;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [self.foregroundColor setFill];
    
    if (self.layer.masksToBounds)
    {
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
        CGContextAddPath(context, rectPath.CGPath);
    }
    else
    {
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:rect];
        CGContextAddPath(context, rectPath.CGPath);
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (view.layer.masksToBounds)
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.frame cornerRadius:view.layer.cornerRadius];
            CGContextAddPath(context, path.CGPath);
        }
        else
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.frame];
            CGContextAddPath(context, path.CGPath);
        }
    }];
    
    CGContextEOFillPath(context);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    CGContextRestoreGState(context);
}

@end
