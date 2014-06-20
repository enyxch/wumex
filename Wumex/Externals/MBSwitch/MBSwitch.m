//
//  MBSwitch.m
//  MBSwitchDemo
//
//  Created by Mathieu Bolard on 22/06/13.
//  Copyright (c) 2013 Mathieu Bolard. All rights reserved.
//

#import "MBSwitch.h"
#import <QuartzCore/QuartzCore.h>


@interface MBSwitch () <UIGestureRecognizerDelegate> {
    CAShapeLayer *_thumbLayer;
    CAShapeLayer *_fillLayer;
    CALayer *_textOnLayer;
    CALayer *_textOffLayer;
    CAShapeLayer *_backLayer;
    UILabel *_labelOn;
    UILabel *_labelOff;
    BOOL _dragging;
    BOOL _on;
}
@property (nonatomic, assign) BOOL pressed;
- (void) setBackgroundOn:(BOOL)on animated:(BOOL)animated;
- (void) showFillLayer:(BOOL)show animated:(BOOL)animated;
- (CGRect) thumbFrameForState:(BOOL)isOn;
@end

@implementation MBSwitch

@synthesize thumbTintColor = _thumbTintColor;
@synthesize textOnColor = _textOnColor;
@synthesize textOffColor = _textOffColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super initWithCoder:aDecoder]) ){
        [self layoutIfNeeded];
        [self configure];
    }
    return self;
}

- (void) configure {
    //Check width > height
    
    _thumbLayer = nil;
    _fillLayer = nil;
    _textOnLayer = nil;
    _textOffLayer = nil;
    _backLayer = nil;
    self.layer.sublayers = nil;
    
    CGSize textOffSize = [_textOff sizeWithFont:[UIFont systemFontOfSize:self.bounds.size.height/2]];
    CGSize textOnSize = [_textOn sizeWithFont:[UIFont systemFontOfSize:self.bounds.size.height/2]];
    
    CGFloat maxWidth = MAX(MAX(textOffSize.width, textOnSize.width), self.frame.size.height*0.5);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.height+ maxWidth + 20, self.frame.size.height);
    
    for( NSLayoutConstraint *constraint in self.constraints) {
        
        if(constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = self.frame.size.width;
        }
    }
    
    _labelOff = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.height +10, self.bounds.origin.y, self.bounds.size.width-self.bounds.size.height-20, self.bounds.size.height)];
    _labelOff.text = _textOff;
    [_labelOff setTextAlignment:NSTextAlignmentCenter];
    [_labelOff setFont:[UIFont systemFontOfSize:self.bounds.size.height/2]];
    if (_textOffColor) {
        _labelOff.textColor = _textOffColor;
    }
    
    _labelOn = [[UILabel alloc] initWithFrame:CGRectMake( 10, self.bounds.origin.y, self.bounds.size.width-self.bounds.size.height-20, self.bounds.size.height)];
    _labelOn.text = _textOn;
    [_labelOn setTextAlignment:NSTextAlignmentCenter];
    [_labelOn setFont:[UIFont systemFontOfSize:self.bounds.size.height/2]];
    if (_textOnColor) {
        _labelOn.textColor = _textOnColor;
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _onTintColor = [UIColor colorWithRed:0.27f green:0.85f blue:0.37f alpha:1.00f] ;
    [self setBacklayerOnTintColorIfNeeded];
    
    _tintColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f] ;
    [self setBacklayerTintColorIfNeeded];
    
    _on = NO;
    _pressed = NO;
    _dragging = NO;
    
    
    _backLayer = [CAShapeLayer layer] ;
    _backLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _backLayer.frame = self.bounds;
    CGPathRef path1 = [UIBezierPath bezierPathWithRoundedRect:_backLayer.bounds cornerRadius:floorf(self.bounds.size.height/2.0)].CGPath;
    _backLayer.path = path1;
    [_backLayer setValue:@NO forKey:@"isOn"];
    _backLayer.fillColor = [UIColor blackColor].CGColor;
    
    [self.layer addSublayer:_backLayer];
    
    _fillLayer = [CAShapeLayer layer] ;
    _fillLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _fillLayer.frame = CGRectInset(self.bounds, 1.5, 1.5);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_fillLayer.bounds cornerRadius:floorf(_fillLayer.bounds.size.height/2.0-1)].CGPath;
    _fillLayer.path = path;
    [_fillLayer setValue:@YES forKey:@"isVisible"];
    _fillLayer.fillColor = [[UIColor whiteColor] CGColor];
    
    [self.layer addSublayer:_fillLayer];
    
    _textOffLayer = _labelOff.layer;
    [_textOffLayer setValue:@NO forKey:@"isOn"];
    [self.layer addSublayer:_textOffLayer];
    _textOnLayer = _labelOn.layer;
    _textOnLayer.opacity = 0.f;
    [self.layer addSublayer:_textOnLayer];
    
    _thumbLayer = [CAShapeLayer layer] ;
    _thumbLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _thumbLayer.frame = [self thumbFrameForState:_on];
    _thumbLayer.cornerRadius = _thumbLayer.frame.size.height/2.0;
    CGPathRef knobPath = [UIBezierPath bezierPathWithRoundedRect:_thumbLayer.bounds cornerRadius:floorf(_thumbLayer.bounds.size.height/2.0)].CGPath;
    _thumbLayer.path = knobPath;
    _thumbLayer.fillColor = [UIColor whiteColor].CGColor;
//    _thumbLayer.shadowColor = [UIColor blackColor].CGColor;
//    _thumbLayer.shadowOffset = CGSizeMake(0.0, 3.0);
//    _thumbLayer.shadowRadius = 3.0;
//    _thumbLayer.shadowOpacity = 0.3;
    _thumbLayer.borderColor = [UIColor darkGrayColor].CGColor;
    _thumbLayer.borderWidth = 1.f;
    
    [self.layer addSublayer:_thumbLayer];
    
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapped:)];
	[tapGestureRecognizer setDelegate:self];
	[self addGestureRecognizer:tapGestureRecognizer];
    
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(toggleDragged:)];
	[panGestureRecognizer setDelegate:self];
	[self addGestureRecognizer:panGestureRecognizer];
    
    [self setBacklayerTintColorIfNeeded];
    [self setBacklayerOnTintColorIfNeeded];
    [self setOffTintColor:self.offTintColor];
    if (_thumbTintColor) {
        _thumbLayer.fillColor = _thumbTintColor.CGColor;
    }
    
}

#pragma mark -
#pragma mark Animations

- (BOOL) isOn {
    return _on;
}

- (void) setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    
    if (_on != on) {
        _on = on;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }

    [CATransaction begin];
    if (animated) {
        [CATransaction setAnimationDuration:0.3];
        [CATransaction setDisableActions:NO];
        _thumbLayer.frame = [self thumbFrameForState:_on];
    }else {
        [CATransaction setDisableActions:YES];
        _thumbLayer.frame = [self thumbFrameForState:_on];
    }
    [CATransaction commit];

    [self setBackgroundOn:_on animated:animated];
    [self showFillLayer:!_on animated:animated];
    [self showTextOn:_on animated:animated];
}

- (void) showTextOn:(BOOL)on animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *animateOffColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOffColor.duration = 0.22;
        animateOffColor.fromValue = @(_textOffLayer.opacity);
        animateOffColor.toValue = on ? @0 : @1;
        animateOffColor.removedOnCompletion = NO;
        animateOffColor.fillMode = kCAFillModeForwards;
        [_textOffLayer addAnimation:animateOffColor forKey:@"animateOpacity"];
        
        CABasicAnimation *animateOnColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animateOnColor.duration = 0.22;
        animateOnColor.fromValue = @(_textOnLayer.opacity);
        animateOnColor.toValue = on ? @1 : @0;
        animateOnColor.removedOnCompletion = NO;
        animateOnColor.fillMode = kCAFillModeForwards;
        [_textOnLayer addAnimation:animateOnColor forKey:@"animateOpacity"];
        [CATransaction commit];
    }else {
        [_textOffLayer removeAllAnimations];
        [_textOnLayer removeAllAnimations];
        _textOffLayer.opacity = on ? 0 : 1;
        _textOnLayer.opacity = on ? 1 : 0;
    }
    [self showTextOnPercent:on ? 1 : 0];
}


- (void) showTextOnPercent:(CGFloat)percent
{
    [_textOffLayer removeAllAnimations];
    [_textOnLayer removeAllAnimations];
    
    CAShapeLayer *maskOff = [CAShapeLayer layer] ;
    maskOff.backgroundColor = [[UIColor whiteColor] CGColor];
    maskOff.frame = CGRectMake(_thumbLayer.frame.origin.x - _thumbLayer.frame.size.width / 2, self.bounds.origin.y, self.bounds.size.width - (_thumbLayer.frame.origin.x + _thumbLayer.frame.size.width/2), self.bounds.size.height);
    
    _textOffLayer.mask = maskOff;
    
    CAShapeLayer *maskOn = [CAShapeLayer layer] ;
    maskOn.backgroundColor = [[UIColor whiteColor] CGColor];
    maskOn.frame = CGRectMake( 0, self.bounds.origin.y, _thumbLayer.frame.origin.x, self.bounds.size.height);
    
    _textOnLayer.mask = maskOn;
    
    _textOffLayer.opacity = 1 - percent;
    _textOnLayer.opacity = percent;
}

- (void) setBackgroundOn:(BOOL)on animated:(BOOL)animated {
    BOOL isOn = [[_backLayer valueForKey:@"isOn"] boolValue];
    if (on != isOn) {
        [_backLayer setValue:@(on) forKey:@"isOn"];
        if (animated) {
            CABasicAnimation *animateColor = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            animateColor.duration = 0.22;
            animateColor.fromValue = on ? (id)_tintColor.CGColor : (id)_onTintColor.CGColor;
            animateColor.toValue = on ? (id)_onTintColor.CGColor : (id)_tintColor.CGColor;
            animateColor.removedOnCompletion = NO;
            animateColor.fillMode = kCAFillModeForwards;
            [_backLayer addAnimation:animateColor forKey:@"animateColor"];
            [CATransaction commit];
        }else {
            [_backLayer removeAllAnimations];
            _backLayer.fillColor = on ? _onTintColor.CGColor : _tintColor.CGColor;
        }
    }
}

- (void) showFillLayer:(BOOL)show animated:(BOOL)animated {
    BOOL isVisible = [[_fillLayer valueForKey:@"isVisible"] boolValue];
    if (isVisible != show) {
        [_fillLayer setValue:@(show) forKey:@"isVisible"];
        CGFloat scale = show ? 1.0 : 0.0;
        if (animated) {
            CGFloat from = show ? 0.0 : 1.0;
            CABasicAnimation *animateScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            animateScale.duration = 0.22;
            animateScale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(from, from, 1.0)];
            animateScale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
            animateScale.removedOnCompletion = NO;
            animateScale.fillMode = kCAFillModeForwards;
            animateScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_fillLayer addAnimation:animateScale forKey:@"animateScale"];
        }else {
            [_fillLayer removeAllAnimations];
            _fillLayer.transform = CATransform3DMakeScale(scale,scale,1.0);
        }
    }
}

- (void) setPressed:(BOOL)pressed {
    if (_pressed != pressed) {
        _pressed = pressed;
        
        if (!_on) {
            [self showFillLayer:!_pressed animated:YES];
        }
    }
}

#pragma mark -
#pragma mark Appearance

- (void) setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor ;
    [self setBacklayerTintColorIfNeeded];
}

- (void)setBacklayerTintColorIfNeeded
{
    if (![[_backLayer valueForKey:@"isOn"] boolValue]) {
        _backLayer.fillColor = [_tintColor CGColor];
    }
}

- (void) setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self setBacklayerOnTintColorIfNeeded];
}

- (void)setBacklayerOnTintColorIfNeeded
{
    if ([[_backLayer valueForKey:@"isOn"] boolValue]) {
        _backLayer.fillColor = [_onTintColor CGColor];
    }
}

- (void) setOffTintColor:(UIColor *)offTintColor {
    _fillLayer.fillColor = [offTintColor CGColor];
}

- (UIColor *) offTintColor {
    return [UIColor colorWithCGColor:_fillLayer.fillColor];
}

- (void) setThumbTintColor:(UIColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    _thumbLayer.fillColor = [thumbTintColor CGColor];
}

- (UIColor *) thumbTintColor {
    return [UIColor colorWithCGColor:_thumbLayer.fillColor];
}

- (void) setEnabled:(BOOL)enabled
{
    self.alpha = enabled ? 1.f : .5f;
    [super setEnabled:enabled];
}

- (void)setTextOff:(NSString *)textOff
{
    _textOff = textOff ;
    [self configure];
}

- (void)setTextOn:(NSString *)textOn
{
    _textOn = textOn;
    [self configure];
}

- (void)setTextOnColor:(UIColor *)textOnColor
{
    _textOnColor = textOnColor;
    [self configure];
}

- (void)setTextOffColor:(UIColor *)textOffColor
{
    _textOffColor = textOffColor;
    [self configure];
}

#pragma mark -
#pragma mark Interaction

- (void)tapped:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded)
		[self setOn:!self.on animated:YES];
}

- (void)toggleDragged:(UIPanGestureRecognizer *)gesture
{
	CGFloat minToggleX = 1.0;
	CGFloat maxToggleX = self.bounds.size.width-self.bounds.size.height+1.0;
    
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		self.pressed = YES;
        _dragging = YES;
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];
        
		[CATransaction setDisableActions:YES];
        
		self.pressed = YES;
        
		CGFloat newX = _thumbLayer.frame.origin.x + translation.x;
		if (newX < minToggleX) newX = minToggleX;
		if (newX > maxToggleX) newX = maxToggleX;
		_thumbLayer.frame = CGRectMake(newX,
                                       _thumbLayer.frame.origin.y,
                                       _thumbLayer.frame.size.width,
                                       _thumbLayer.frame.size.height);
        
        CGFloat percent = newX / maxToggleX;
//        NSLog(@"percent : %f - newX : %f - translation.x : %f", percent, newX, translation.x);
        
        [self showTextOnPercent:percent];
        
        if (CGRectGetMidX(_thumbLayer.frame) > CGRectGetMidX(self.bounds)
            && ![[_backLayer valueForKey:@"isOn"] boolValue]) {
            [self setBackgroundOn:YES animated:YES];
        }else if (CGRectGetMidX(_thumbLayer.frame) < CGRectGetMidX(self.bounds)
                  && [[_backLayer valueForKey:@"isOn"] boolValue]){
            [self setBackgroundOn:NO animated:YES];
        }
        
        
		[gesture setTranslation:CGPointZero inView:self];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
		CGFloat toggleCenter = CGRectGetMidX(_thumbLayer.frame);
        [self setOn:(toggleCenter > CGRectGetMidX(self.bounds)) animated:YES];
        _dragging = NO;
        self.pressed = NO;
	}
    
	CGPoint locationOfTouch = [gesture locationInView:self];
	if (CGRectContainsPoint(self.bounds, locationOfTouch))
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	else
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    
    self.pressed = YES;
	
	[self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
    if (!_dragging) {
        self.pressed = NO;
    }
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
    if (!_dragging) {
        self.pressed = NO;
    }
	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark -
#pragma mark Thumb Frame

- (CGRect) thumbFrameForState:(BOOL)isOn {
    return CGRectMake(isOn ? self.bounds.size.width-self.bounds.size.height+1.0 : 1.0,
                      1.0,
                      self.bounds.size.height-2.0,
                      self.bounds.size.height-2.0);
}

@end
