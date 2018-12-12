//
//  ChatListView.m
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "ChatListView.h"
#import "UIColor+JabberCHIColors.h"

@implementation ChatListView


- (instancetype) initWithDelegate: (id<ChatListViewDelegate>) aDelegate;
{
    self = [super init];
    if (self)
    {
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems :@[ NSLocalizedString(@"All users", nil), NSLocalizedString(@"Online", nil)]];
        [[UISegmentedControl appearance] setTintColor: [UIColor segmentedControlColor]];
        [[UISegmentedControl appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor segmentedControlColor]}
                                                       forState: UIControlStateNormal];
        [self.segmentedControl addTarget: self
                                  action: @selector(changeSegmentedControl)
                        forControlEvents: UIControlEventValueChanged];
        self.segmentedControl.selectedSegmentIndex = 0;
        
        [self addSubview: self.segmentedControl];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = aDelegate;
        self.tableView.delegate   = aDelegate;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat topOffset = 15.5f;
    self.segmentedControl.frame = CGRectMake(self.frame.size.width / 2 - 135, topOffset, 270, 35);
    self.tableView.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.segmentedControl.frame) + 7.5,
                                      self.frame.size.width,
                                      self.frame.size.height - self.segmentedControl.frame.size.height + topOffset);
}


- (void) changeSegmentedControl
{
    if ([(NSObject*)self.delegate respondsToSelector: @selector(segmentedControlTabWillChange)])
    {
        [self.delegate segmentedControlTabWillChange];
    }
}

@end
