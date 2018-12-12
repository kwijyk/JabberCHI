//
//  ChatListView.h
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "BaseView.h"

@protocol ChatListViewDelegate <NSObject, UITableViewDataSource, UITableViewDelegate>

@required
- (void) segmentedControlTabWillChange;

@end


@interface ChatListView : BaseView


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) id<ChatListViewDelegate> delegate;


- (instancetype) initWithDelegate: (id<ChatListViewDelegate>) aDelegate;

@end
