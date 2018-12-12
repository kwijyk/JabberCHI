//
//  SearchView.m
//  jabber
//
//  Created by Developer on 9/23/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "SearchView.h"
#import "UIColor+JabberCHIColors.h"

@implementation SearchView

//- (instancetype) init
//{
//    self = [super init];
//    if (self)
//    {
//        self.searchResult = [[UIView alloc] init];
//        
//        self.avatarImageView = [[UIImageView alloc] init];
//        self.addUserButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    }
//    return self;
//}
//
//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    UIImage *plusIcon = [UIImage imageNamed:@"plus_icon.png"];
//    
//    self.searchResult.frame = CGRectMake(0, 100, self.frame.size.width, 64);
//    [self addSubview:self.searchResult];
//    
//    self.addUserButton.frame = CGRectMake(self.frame.size.width - plusIcon.size.width - 10,
//                                          (self.frame.size.height - plusIcon.size.height) / 2,
//                                          plusIcon.size.width,
//                                          plusIcon.size.height);
//    [self.searchResult addSubview:self.addUserButton];
//
//    
//    CGFloat avatarSize = 50.0f;
//    self.avatarImageView.frame = CGRectMake(15.5, 7.5, avatarSize, avatarSize);
//    self.avatarImageView.layer.cornerRadius = avatarSize / 2;
//    self.avatarImageView.layer.masksToBounds = YES;
//    self.avatarImageView.clipsToBounds = YES;
//    [self.searchResult addSubview:self.avatarImageView];
//
//    
//    CGFloat nameWidth = self.frame.size.width - 15.5 * 2 - avatarSize - plusIcon.size.width;
//    self.userNameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 14.5,
//                                             27,
//                                             nameWidth,
//                                             14);
//    [self.searchResult addSubview:self.userNameLabel];
//    
//
//    
//    
//    
//}

- (instancetype) initWithDelegate:(id<UITableViewDelegate,UITableViewDataSource>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self.delegate;
        self.tableView.delegate   = self.delegate;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    [self.tableView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

}

@end
