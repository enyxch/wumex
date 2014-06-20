//
//  WUAppDelegate.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUAppDelegate.h"

#import "MRoundedButton.h"
#import "WULoginViewController.h"
#import "IQKeyboardManager.h"

#import "WUObjectToJSONMapper.h"
#import "WUJSONToObjectMapper.h"

#import "WUUser.h"
#import "WUProject.h"
#import "WULabel.h"
#import "WUTask.h"

@implementation WUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
//                                                          nil]];
    
    // Rounded Button
    NSDictionary *appearanceProxy1 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @2,
                                       kMRoundedButtonBorderColor  : [[UIColor blackColor] colorWithAlphaComponent:0.25],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimationColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [[UIColor whiteColor] colorWithAlphaComponent:0.25],
                                       kMRoundedButtonForegroundAnimationColor : [UIColor clearColor]};
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy1 forIdentifier:@"1"];
    
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:YES];
    [[IQKeyboardManager sharedManager] setShouldPlayInputClicks:YES];
    
    // object mapping configuration
    // for WUUser
    [WUObjectToJSONMapper registerMapping:[WUUser getObjectToJSONMapping] forClass:[WUUser class]];
    [WUJSONToObjectMapper registerMapping:[WUUser getJSONToObjectMapping] forClass:[WUUser class]];
    // for WUProject
    [WUObjectToJSONMapper registerMapping:[WUProject getObjectToJSONMapping] forClass:[WUProject class]];
    [WUJSONToObjectMapper registerMapping:[WUProject getJSONToObjectMapping] forClass:[WUProject class]];
    // for WULabel
    [WUObjectToJSONMapper registerMapping:[WULabel getObjectToJSONMapping] forClass:[WULabel class]];
    [WUJSONToObjectMapper registerMapping:[WULabel getJSONToObjectMapping] forClass:[WULabel class]];
    // for WUTask
    [WUObjectToJSONMapper registerMapping:[WUTask getObjectToJSONMapping] forClass:[WUTask class]];
    [WUJSONToObjectMapper registerMapping:[WUTask getJSONToObjectMapping] forClass:[WUTask class]];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // show the storyboard
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];

    [self login];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)login
{
    WULoginViewController* viewController = [[WULoginViewController alloc] initWithNibName:@"WULoginViewController" bundle:nil];
    
    // Present ;
    [self.window.rootViewController presentViewController:viewController animated:NO completion:^{
        
    }];
}

@end
