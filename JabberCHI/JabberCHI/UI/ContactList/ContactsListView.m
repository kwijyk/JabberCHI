//
//  ContactsListView.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/9/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "ContactsListView.h"

@implementation ContactsListView

- (instancetype) initWithDelegate:(id<ContactListViewDelegate>) aDelegate
{
    self = [super init];
    if(self)
    {
        self.delegate = aDelegate;
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self.delegate;
        self.tableView.delegate = self.delegate;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = CGRectMake(0,
                                      0,
                                      self.frame.size.width,
                                      self.frame.size.height);
}


@end
