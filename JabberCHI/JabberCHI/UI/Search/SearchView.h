//
//  SearchView.h
//  jabber
//
//  Created by Developer on 9/23/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@interface SearchView : BaseView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id <UITableViewDelegate, UITableViewDataSource > delegate;

- (instancetype) initWithDelegate: (id<UITableViewDelegate, UITableViewDataSource>)delegate;



@end
