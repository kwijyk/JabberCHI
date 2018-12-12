//
//  AppDelegate.m
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatListViewController.h"
#import "LoginViewController.h"
#import "JabberManager.h"
#import "UIColor+JabberCHIColors.h"
#import "UIImage+JabberCHIImage.h"
#import <Reachability.h>
#import "macroses.h"
#import "CHIAlertView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self setupAppearance];
    [self showNeededScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reachabilityDidChange:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    if (![internetReachable isReachable])
    {
        [self showNoInternetAlert];
    }
    
    return YES;
}

-(void)reachabilityDidChange:(NSNotification*)notification
{
    Reachability *reachability = notification.object;
    if ([reachability isReachable])
    {
        [[JabberManager shared] connect];
    }
    else
    {
        [self showNoInternetAlert];
    }
}

- (void) showNeededScreen
{
    NSString *name =  [[NSUserDefaults standardUserDefaults] objectForKey:@"LogInName"];
    if(name.length)
    {
        [[JabberManager shared] connect];
        [self showMainScreen];
    }
    else
    {
        [self showLoginScreen];
    }
}

- (void) showNoInternetAlert
{
    CHIAlertView *internetConnectionAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No internet connection", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"Ok"];
    [internetConnectionAlert show];
}

- (void) showMainScreen
{
    self.tabBarController         = [[CHIJabberTabBarController alloc] init];
    self.window.rootViewController = self.tabBarController;
    
}
- (void) showLoginScreen
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;
}
- (void) setupAppearance
{
    [[UIToolbar appearance] setBarTintColor:[UIColor mainColor]];
    
    [[UINavigationBar appearance] setTintColor: [UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor: [UIColor mainColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName:
                                                                 [UIColor whiteColor],
                                                             NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light"
                                                                                                  size: 17.0f] }];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{
                                                                                                   NSForegroundColorAttributeName:
                                                                                                       [UIColor whiteColor],
                                                                                                   NSShadowAttributeName: [NSShadow new],
                                                                                                   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f]
                                                                                                   } forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBackgroundColor: [UIColor mainColor]];
    
    //    [[UINavigationBar appearance] setTranslucent: NO];
    //    [[UINavigationBar appearance] setAlpha: 1];
    
    //    [[UINavigationBar appearance] setBackgroundImage: [[UIImage alloc] init]
    //                                      forBarPosition: UIBarPositionAny
    //                                          barMetrics: UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage: [UIImage imageWithColor: [UIColor mainColor]]];
    
    //    if ([UINavigationBar instancesRespondToSelector: @selector(setBackIndicatorImage:)])
    //    {
    //        [[UINavigationBar appearance]  setBackIndicatorImage:[UIImage imageNamed: @"arrow_back"]];
    //        [[UINavigationBar appearance]  setBackIndicatorTransitionMaskImage:[UIImage imageNamed: @"arrow_back"]];
    //    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
