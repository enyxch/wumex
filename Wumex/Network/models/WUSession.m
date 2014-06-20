//
//  WUSession.m
//  Global_Jury
//
//  Created by Sebastian Ewak on 6/28/13.
//  Copyright (c) 2013 Selleo. All rights reserved.
//

#import "WUSession.h"
#import "KeychainItemWrapper.h"
#import "WUJSONToObjectMapper.h"
#import "WUObjectToJSONMapper.h"

static NSString * const kWUSessionKeychainIdentifier = @"GLOBAL_JURY_SESSION_KEYCHAIN";

@interface WUSession ()

@property (nonatomic, strong) KeychainItemWrapper *keychainItem;

@end

@implementation WUSession

- (id)init
{
    self = [super init];

    if (self != nil)
    {
        // identifier - identifies the keychain item dedicated to the session object
        // accessGroup - value used to share this particular keychain item between different applications
        //               by default only application which created a keychain can access it
        self.keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kWUSessionKeychainIdentifier accessGroup:nil];

        // setting security settings for this keychain item
        // kSecAttrAccessibleUnlockedThisDeviceOnly means that this keychain item will be decrypted only
        //      on this device and only when it's unlocked
        [self.keychainItem setObject:(__bridge NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge NSString *)kSecAttrAccessible];
    }

    return self;
}

// TODO - allow error handling for the caller
- (void)saveSession
{
    if (self.user == nil)
    {
        LogE(@"An error occured when saving session. Can't save session when user is nil!");
    }

    NSError *jsonSerializationError;
    NSString *userJSON = [[WUObjectToJSONMapper defaultMapper] mapObjectToJSON:self.user error:&jsonSerializationError];
    
    NSLog(@"Save user : %@", userJSON);

    if (jsonSerializationError != nil)
    {
        LogE(@"An error occured when saving session. User to JSON serialization failed due to following error: %@", [jsonSerializationError localizedDescription]);
    }
    else
    {
        [self.keychainItem setObject:userJSON forKey:(__bridge NSString *)kSecValueData];
    }
}

- (void)discardSession
{
    self.user = nil;
    [self removeSessionKeychainItem];
}

- (BOOL)isValid
{
    return self.user != nil && self.user.token != nil && ![self.user.token isEqualToString:@""];
}

- (WUUser *)user
{
    if (_user == nil)
    {
        _user = [self fetchUserFromKeychain];
    }

    return _user;
}

+ (WUSession *)sharedSession
{
    static WUSession *sharedSession;
    static dispatch_once_t predicate = 0;

    dispatch_once(&predicate, ^{
        sharedSession = [WUSession new];
    });

    return sharedSession;
}

/** @name private methods */

- (void)removeSessionKeychainItem
{
    [self.keychainItem setObject:@"" forKey:(__bridge NSString *)kSecValueData];
    [self.keychainItem resetKeychainItem];
}

// TODO - allow error handling for the caller
- (WUUser *)fetchUserFromKeychain
{
    WUUser *user;

    /** if userJSON is nil or empty then it means there is no session stored in Keychain - we should return nil then */
    NSString *userJSON = [self.keychainItem objectForKey:(__bridge NSString *)kSecValueData];
    if (userJSON == nil || [userJSON isEqualToString:@""])
    {
        return nil;
    }

    NSError *jsonDeserializationError;
    user = [[WUJSONToObjectMapper defaultMapper] mapJSON:userJSON toObjectOfClass:[WUUser class] error:&jsonDeserializationError];
    if (jsonDeserializationError != nil)
    {
        LogE(@"An error occured when fetching session. User JSON deserialization failed due to following error: %@", [jsonDeserializationError localizedDescription]);
    }

    return user;
}

@end
