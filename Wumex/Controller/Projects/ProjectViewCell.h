//
//  ProjectViewCell.h
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectViewCell : UITableViewCell
{
    @private
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelDescription;
    __weak IBOutlet UILabel *labelTaskNumber;
    __weak IBOutlet UILabel *labelNoteNumber;
    __weak IBOutlet UILabel *labelObserverNumber;
    __weak IBOutlet UILabel *labelTask;
    __weak IBOutlet UILabel *labelNote;
    __weak IBOutlet UILabel *labelObserver;
}

+ (ProjectViewCell*)sharedCell;

- (void)setCellColor:(UIColor*)color;
- (void)setTaskNumber:(NSUInteger)number;
- (void)setNoteNumber:(NSUInteger)number;
- (void)setObserverNumber:(NSUInteger)number;
- (void)setTitle:(NSString*)title;
- (void)setDetails:(NSString*)details;

@end
