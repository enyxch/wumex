//
//  ChatViewCell.h
//  Wumex
//
//  Created by Blerim Bunjaku on 17/12/13.
//  Copyright (c) 2014 Enyx (Swiss) ltd. All rights reserved.
//
// --- Headers --- ;
#import <UIKit/UIKit.h>

// --- Defines --- ;
// ChatViewCell Class;
@interface ChatViewCell : UITableViewCell
{
    IBOutlet UIImageView*       imgForThumbnail;
    IBOutlet UILabel*           lblForTitle;
}

// Functions;
+ (ChatViewCell*)send;
+ (ChatViewCell*)receive;
- (void)setThumbnail:(UIImage*)thumbnail;
- (void)setTitle:(NSString*)title;

@end

