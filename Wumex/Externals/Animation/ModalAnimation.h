//
//  ModalDismissAnimation.h
//  TransitionTest
//
//  Created by Tyler Tillage on 7/3/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

#import "BaseAnimation.h"

@interface ModalAnimation : BaseAnimation

@property (nonatomic) BOOL shouldDismissOnBackgroundClick;
@property (nonatomic) UIEdgeInsets modalViewEdge;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) NSArray *constraints;
@property (nonatomic, strong) UIViewController *controller;

@end
