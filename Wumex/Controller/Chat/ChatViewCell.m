//
//  ChatViewCell.m
//  Wumex
//
//  Created by Blerim Bunjaku on 17/12/13.
//  Copyright (c) 2014 Enyx (Swiss) ltd. All rights reserved.
//
// --- Headers --- ;
#import "ChatViewCell.h"

// --- Defines --- ;
// ChatViewCell Class;
@implementation ChatViewCell

// Functions;
#pragma mark - Shared Funtions
+ (ChatViewCell*)send
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChatViewCell" owner:nil options:nil];
    ChatViewCell* cell = array[0];
    
    return cell;
}

+ (ChatViewCell*)receive
{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"ChatViewCell" owner:nil options:nil];
    ChatViewCell* cell = array[1];
    
    return cell;
}

#pragma mark - ChatViewCell
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
}

- (void)setThumbnail:(UIImage*)thumbnail
{
    [imgForThumbnail setImage:thumbnail];
}

- (void)setTitle:(NSString*)title
{
    [lblForTitle setText:title];
}

@end
