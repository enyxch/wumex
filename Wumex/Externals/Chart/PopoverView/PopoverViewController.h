//
//  PopoverViewController.h
//  ChatHeads
//
//  Created by Nicolas Bonnet on 12.05.14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PopoverViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (copy) void (^blockClose)(void);

@end
