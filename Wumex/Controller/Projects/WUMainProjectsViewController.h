//
//  WUMainProjectsViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WUMainViewController.h"

@interface WUMainProjectsViewController : WUMainViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray* listOfProject;

//@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@end
