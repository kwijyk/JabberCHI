//
//  CHIJabberTabBar.h
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatListViewController.h"
#import "SettingsViewController.h"
#import "ContactListViewController.h"
#import "SearchViewController.h"


@interface CHIJabberTabBarController : UITabBarController


@property (nonatomic, readonly) ChatListViewController *chatListViewController;
@property (nonatomic, readonly) SettingsViewController *settngsViwController;
@property (nonatomic, readonly) ContactListViewController *contactsViewController;
@property (nonatomic, readonly) SearchViewController *searchViewController;

- (void)openChats;
- (void)openSettings;
- (void)openContacts;

@end
