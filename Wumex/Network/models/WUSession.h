//
//  WUSession.h
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/28/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WUUser.h"

@interface WUSession : NSObject

@property (nonatomic, strong) WUUser *user;

- (void)saveSession;

- (void)discardSession;

- (BOOL)isValid;

- (WUUser *)user;

@end
