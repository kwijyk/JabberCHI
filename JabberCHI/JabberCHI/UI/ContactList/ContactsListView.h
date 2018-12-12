//
//  ContactsListView.h
//  CHIJabberClient
//
//  Created by CHI Developer on 7/9/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "BaseView.h"

@protocol ContactListViewDelegate <NSObject, UITableViewDataSource, UITableViewDelegate>



@end

@interface ContactsListView : BaseView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<ContactListViewDelegate> delegate;

//- (instancetype) initWithDelegate:(id<ContactListViewDelegate>) aDelegate NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithDelegate:(id<ContactListViewDelegate>) aDelegate;


@end
