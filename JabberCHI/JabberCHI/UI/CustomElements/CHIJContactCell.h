//
//  CHIJContactCell.h
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHIJContactCell : UITableViewCell


@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel     *accountNameLabel;
@property (nonatomic, assign) BOOL        isOnline;
@property (nonatomic, assign) NSNumber    *unreadMessagesCount;
@property (nonatomic, strong) UIButton    *addUserButton;
@property (nonatomic, strong) UILabel     *unreadLabel;


- (instancetype) initWithStyle: (UITableViewCellStyle) style
               reuseIdentifier: (NSString*) reuseIdentifier
                      isSearch: (BOOL) isSearch;


@end
