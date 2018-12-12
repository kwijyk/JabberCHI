//
//  AppDelegate.h
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHIJabberTabBarController.h"
#import "JabberManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) CHIJabberTabBarController * tabBarController;

- (void) showMainScreen;
- (void) showLoginScreen;
- (void) showNoInternetAlert;

@end

