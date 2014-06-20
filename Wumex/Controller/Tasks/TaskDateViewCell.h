//
//  TaskDateViewCell.h
//  Wumex
//
//  Created by Nicolas Bonnet on 17.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKInnerShadowLayer.h"

@interface TaskDateViewCell : UITableViewCell
{
@private
    
    __weak IBOutlet UILabel *labelDate;
    SKInnerShadowLayer *innerShadowlayer;
}

- (void)setText:(NSString *)text;

+ (TaskDateViewCell*)sharedCell;

- (void)showTopShadow:(BOOL)show;

@end
