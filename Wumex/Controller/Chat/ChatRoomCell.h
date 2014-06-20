//
//  ChatRoomCell.h
//  Wumex
//
//  Created by Blerim Bunjaku on 17/12/13.
//  Copyright (c) 2014 Enyx (Swiss) ltd. All rights reserved.
//
// --- Headers --- ;
#import <UIKit/UIKit.h>

// --- Defines --- ;
// ChatRoomCell Class;
@interface ChatRoomCell : UITableViewCell
{
    IBOutlet UIImageView*       imgFirst;
    IBOutlet UILabel*           lblForTitle;
}

// Functions;
+ (ChatRoomCell*)sharedCell;
- (void)setImgFirstImage:(UIImage*)image;
- (void)setTitle:(NSString*)title;

@end

// ChatMeetCell Class;
@interface ChatRoomTwoCell : UITableViewCell
{
    IBOutlet UIImageView*       imgFirst;
    IBOutlet UIImageView*       imgSecond;
    IBOutlet UILabel*           lblForTitle;
}

// Functions;
+ (ChatRoomTwoCell*)sharedCell;
- (void)setImgFirstImage:(UIImage*)image;
- (void)setImgSecondImage:(UIImage*)image;
- (void)setTitle:(NSString*)title;

@end

// ChatMeetCell Class;
@interface ChatRoomThreeCell : UITableViewCell
{
    IBOutlet UIImageView*       imgFirst;
    IBOutlet UIImageView*       imgSecond;
    IBOutlet UIImageView*       imgThird;
    IBOutlet UILabel*           lblForTitle;
}

// Functions;
+ (ChatRoomThreeCell*)sharedCell;
- (void)setImgFirstImage:(UIImage*)image;
- (void)setImgSecondImage:(UIImage*)image;
- (void)setImgThirdImage:(UIImage*)image;
- (void)setTitle:(NSString*)title;

@end
