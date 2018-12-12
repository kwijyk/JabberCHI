//
//  CHIJabberTabBar.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "CHIJabberTabBarController.h"

//static const int kContactsIndex = 0;
static const int kChatsIndex = 0;
static const int kSettingsIndex = 1;
static const int kSearchIndex = 2;

@implementation CHIJabberTabBarController

@synthesize chatListViewController = _chatListViewController;
@synthesize settngsViwController = _settngsViwController;
@synthesize contactsViewController = _contactsViewController;
@synthesize searchViewController = _searchViewController;


- (instancetype) init
{
    self = [super init];
    if(self)
    {
        UINavigationController *chatsNavigation = [[UINavigationController alloc] initWithRootViewController: self.chatListViewController];

        UINavigationController *setteingsNavigation = [[UINavigationController alloc] initWithRootViewController: self.settngsViwController];
        
        UINavigationController *searchNavigation = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
        NSArray *viewControllersArray = @[chatsNavigation, setteingsNavigation, searchNavigation];
        
        self.viewControllers = viewControllersArray;
        
        UITabBarItem *chats = [self.tabBar.items objectAtIndex:0];
        chats.image = [[UIImage imageNamed: @"icn_chat_unact"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        chats.selectedImage = [[UIImage imageNamed:@"icn_chat"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];;
        
        UITabBarItem *settings = [self.tabBar.items objectAtIndex:1];
        settings.image =[[UIImage imageNamed:@"icn_swithes_unact"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        settings.selectedImage = [[UIImage imageNamed:@"icn_swithes"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];

        
        UITabBarItem *search = [self.tabBar.items objectAtIndex:2];
        search.image = [[UIImage imageNamed:@"search_unact"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        search.selectedImage = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        chats.title    = nil;
        settings.title = nil;
    }
    return self;
}

- (void) viewDidLoad
{
//        [self.tabBar setBackgroundColor: [UIColor blueColor]];
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:transparentImage];
    [self.tabBar setShadowImage:transparentImage];
}

#pragma mark - Accesors

- (ChatListViewController*) chatListViewController
{
   if(!_chatListViewController)
   {
       _chatListViewController = [[ChatListViewController alloc] init];
   }
    return _chatListViewController;
}

- (ContactListViewController*) contactsViewController
{
    if(!_contactsViewController)
    {
        _contactsViewController =  [[ContactListViewController alloc] init];
    }
    return _contactsViewController;
}

- (SettingsViewController*) settngsViwController
{
    if(!_settngsViwController)
    {
        _settngsViwController = [[SettingsViewController alloc] init];
    }
    return _settngsViwController;
}

- (SearchViewController*) searchViewController
{
    if (!_searchViewController)
    {
        _searchViewController = [[SearchViewController alloc] init];
    }
    return  _searchViewController;
}

#pragma mark - Open Needed screen

- (void) openChats
{
    self.selectedIndex = kChatsIndex;
}
- (void) openContacts
{
//    self.selectedIndex = kContactsIndex;
}
- (void) openSettings
{
    self.selectedIndex = kSettingsIndex;
}
- (void) searchUsers
{
    self.selectedIndex = kSearchIndex;
}

@end
