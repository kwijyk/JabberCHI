//
//  SearchViewController.h
//  jabber
//
//  Created by Developer on 9/21/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatListViewController.h"


@interface SearchViewController : ChatListViewController
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate
>


@end
