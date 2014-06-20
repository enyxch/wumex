//
//  ChatRoomCell.m
//  Wumex
//
//  Created by Blerim Bunjaku on 17/12/13.
//  Copyright (c) 2014 Enyx (Swiss) ltd. All rights reserved.
//
// --- Headers --- ;
#import "ChatRoomCell.h"

// --- Defines --- ;
// ChatRoomCell Class;
@implementation ChatRoomCell

// Functions;
#pragma mark - Shared Funtions
+ (ChatRoomCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChatRoomCell" owner:nil options:nil];
    ChatRoomCell* cell = array[0];
    
    return cell;
}

#pragma mark - ChatRoomCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Set
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self setSelected:NO animated:YES];
    }
}

- (void)setImgFirstImage:(UIImage*)image
{
    imgFirst.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgFirst.layer.masksToBounds = YES;
    imgFirst.image = image;
}

- (void)setTitle:(NSString*)title
{
    [lblForTitle setText:title];
}

@end

// ChatRoomTwoCell Class;
@implementation ChatRoomTwoCell

// Functions;
#pragma mark - Shared Funtions
+ (ChatRoomTwoCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChatRoomCell" owner:nil options:nil];
    ChatRoomTwoCell* cell = array[1];
    
    return cell;
}

#pragma mark - ChatRoomTwoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Set
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self setSelected:NO animated:YES];
    }
}

- (void)setTitle:(NSString*)title
{
    [lblForTitle setText:title];
}

- (void)setImgFirstImage:(UIImage*)image
{
    imgFirst.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgFirst.layer.masksToBounds = YES;
    imgFirst.image = image;
}

- (void)setImgSecondImage:(UIImage*)image
{
    imgSecond.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgSecond.layer.masksToBounds = YES;
    imgSecond.image = [UIHelper maskImage:[UIHelper getResizeAndCropImage:image forMaskSize:imgSecond.bounds.size] withMask:[UIImage imageNamed:@"chat_room_two_mask"]];
}

@end

// ChatRoomThreeCell Class;
@implementation ChatRoomThreeCell

// Functions;
#pragma mark - Shared Funtions
+ (ChatRoomThreeCell*)sharedCell
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChatRoomCell" owner:nil options:nil];
    ChatRoomThreeCell* cell = array[2];
    
    return cell;
}

#pragma mark - ChatRoomThreeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Set
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self setSelected:NO animated:YES];
    }
}

- (void)setImgFirstImage:(UIImage*)image
{
    imgFirst.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgFirst.layer.masksToBounds = YES;
    imgFirst.image = image;
}

- (void)setImgSecondImage:(UIImage *)image
{
    imgSecond.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgSecond.layer.masksToBounds = YES;
    imgSecond.image = image;
}

- (void)setImgThirdImage:(UIImage *)image
{
    imgThird.layer.cornerRadius = imgFirst.bounds.size.width/2;
    imgThird.layer.masksToBounds = YES;
    imgThird.image = image;
}

- (void)setTitle:(NSString*)title
{
    [lblForTitle setText:title];
}

@end

