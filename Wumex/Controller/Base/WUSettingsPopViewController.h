//
//  WUSettingsTableViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WUSettingsDelegate
@required
- (void)settingsView:(UIViewController*)viewController didSelectAction:(NSInteger)action;
@end

@interface WUSettingsPopViewController : UITableViewController

@property (nonatomic, copy) NSArray* listAction;
@property (nonatomic, assign) NSObject<WUSettingsDelegate>* delegate;

@end
