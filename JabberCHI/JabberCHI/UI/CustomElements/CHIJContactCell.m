//
//  CHIJContactCell.m
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "CHIJContactCell.h"
#import "UIFont+JabberCHIFonts.h"
#import "UIImage+JabberCHIImage.h"
#import "UIColor+JabberCHIColors.h"

@interface CHIJContactCell ()

@property (nonatomic, strong) UIImageView *onlineDot;

@end

@implementation CHIJContactCell


- (instancetype) initWithStyle: (UITableViewCellStyle) style
               reuseIdentifier: (NSString*) reuseIdentifier
                      isSearch: (BOOL) isSearch
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self)
    {
        [self setupAvatarImageView];
        [self setupAccountNameLabel];
        if (isSearch == YES)
        {
            [self setupAddButton];
        }
        else
        {
            [self setupUnreadLabel];

        }
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat avatarSize = 50.0f;
    self.avatarImageView.frame = CGRectMake(15.5, 7.5, avatarSize, avatarSize);
    self.avatarImageView.clipsToBounds = YES;
//    self.avatarImageView.image = [self.avatarImageView.image imageInEllipse];
    self.avatarImageView.layer.cornerRadius = avatarSize / 2;
    
    CGFloat onlineDotSize = 11.0f;
    self.onlineDot.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) - onlineDotSize,
                                      CGRectGetMinY(self.avatarImageView.frame) + onlineDotSize / 2,
                                      onlineDotSize,
                                      onlineDotSize);
    
    
    CGFloat nameWidth = [self labelLengthWithText: self.accountNameLabel.text];
    self.accountNameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 14.5,
                                             27,
                                             nameWidth,
                                             14);
    
    CGFloat unreadLabelSize = 16.0f;
    self.unreadLabel.layer.cornerRadius = unreadLabelSize / 2;
    self.unreadLabel.layer.masksToBounds = YES;
    self.unreadLabel.layer.borderWidth = 2;
    self.unreadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.unreadLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) - unreadLabelSize,
                                        CGRectGetMinY(self.avatarImageView.frame),
                                        unreadLabelSize,
                                        unreadLabelSize);
    UIImage *plusIcon = [UIImage imageNamed:@"plus_icon.png"];
    
    self.addUserButton.frame = CGRectMake(self.frame.size.width - plusIcon.size.width - 25,
                                          (self.frame.size.height - plusIcon.size.height) / 2,
                                          plusIcon.size.width,
                                          plusIcon.size.height);
    [self.addUserButton setImage:plusIcon forState:UIControlStateNormal];
    
}

- (void) setupAddButton
{
    self.addUserButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.addUserButton];
}


- (void) setupAvatarImageView
{
    self.avatarImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    
    [self addSubview: self.avatarImageView];
}


- (void) setupAccountNameLabel
{
    self.accountNameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    self.accountNameLabel.font = [UIFont helveticaNeueCyrLightWithSize: 12.0f];
    
    [self addSubview: self.accountNameLabel];
}

- (void) setupOnlineDor
{
    self.onlineDot = [[UIImageView alloc] initWithFrame: CGRectZero];
    self.onlineDot.image = [UIImage imageNamed: @"online_btn"];
    
    [self addSubview: self.onlineDot];
}

- (void) setupUnreadLabel
{
    self.unreadLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    [self.unreadLabel setBackgroundColor:[UIColor segmentedControlColor]];
//    self.unreadLabel.text = [unreadMessagesCount stringValue];
    self.unreadLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:8.0f];
    [self.unreadLabel setTextAlignment:NSTextAlignmentCenter];
    [self.unreadLabel setTextColor:[UIColor whiteColor]];
    
    [self addSubview: self.unreadLabel];
}

- (void) setIsOnline: (BOOL)isOnline
{
    if (isOnline)
    {
        [self setupOnlineDor];
        [self layoutSubviews];
    }
}

- (void) setUnreadMessagesCount: (NSNumber*) unreadMessagesCount
{
    if (unreadMessagesCount.integerValue >0)
    {
        self.unreadLabel.text = [unreadMessagesCount stringValue];
        self.unreadLabel.hidden = NO;
        [self bringSubviewToFront:self.unreadLabel];
    }
    else
    {
         self.unreadLabel.hidden = YES;
    }
}

- (float) labelLengthWithText : (NSString*) text
{
    return [text boundingRectWithSize: self.accountNameLabel.frame.size
                              options: NSStringDrawingUsesLineFragmentOrigin
                           attributes: @{ NSFontAttributeName: self.accountNameLabel.font }
                              context: nil].size.width;
}

- (void) hideUnreadMesagesLabel
{
    self.unreadLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
