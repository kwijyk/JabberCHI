//
//  SettingsView.m
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "SettingsView.h"
#import "CHIJButton.h"

#import "XMPPUserCoreDataStorageObject.h"
#import "JabberManager.h"


@implementation SettingsView


- (instancetype) initWithDelegate: (id<SettingsViewDelegate>) aDelegate
{
    self = [self init];
    if(self)
    {
        [self setupChangePhotoButton];
        [self setupUserPictureImageView];
        [self setupAccountNameTextFieldWithDelegate: aDelegate];
        [self setupLogOutButton];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textFieldHeight = 44.0f;
    CGFloat topOffset    = 35.0f;
    CGFloat buttonHeight = 40.0f;
    CGFloat imageSize    = 100.0;
    CGFloat changePhotoButtonWidth = 120.0f;
    
    CGFloat nameLength = [self labelLengthWithText: self.accountNameLabel.text];

    self.accountNameLabel.frame = CGRectMake(self.frame.size.width / 2 - nameLength / 2,
                                                 topOffset,
                                                 nameLength,
                                                 textFieldHeight);
    
    self.userPictureImageView.frame = CGRectMake(self.frame.size.width / 2 - imageSize / 2,
                                                 CGRectGetMaxY(self.accountNameLabel.frame) + 26,
                                                 imageSize,
                                                 imageSize);
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.frame.size.width / 2;
    self.userPictureImageView.clipsToBounds      = YES;
    
    
    self.changePhotoButton.frame = CGRectMake(self.frame.size.width / 2 - changePhotoButtonWidth / 2,
                                              CGRectGetMaxY(self.userPictureImageView.frame),
                                              changePhotoButtonWidth,
                                              44);
    
    
    self.logOutButton.frame = CGRectMake(self.frame.size.width / 2 - 100,
                                         CGRectGetMaxY(self.userPictureImageView.frame) + 49.5 + 12.5,
                                         200,
                                         buttonHeight);
}


- (void) setupAccountNameTextFieldWithDelegate: (id) aDelegate
{
    self.delegate = aDelegate;
    self.accountNameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    self.accountNameLabel.text = NSLocalizedString(@"Account name",nil);
    [self addSubview: self.accountNameLabel];
}


- (void) setupUserPictureImageView
{
    self.userPictureImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    self.userPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview: self.userPictureImageView];
}


- (void) setupLogOutButton
{
    self.logOutButton = [[CHIJButton alloc] init];
    [self.logOutButton setTitle: NSLocalizedString(@"Log Out", nil) forState:UIControlStateNormal];
    [self.logOutButton addTarget:self.delegate action:@selector(logOutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.logOutButton];
}


- (float) labelLengthWithText : (NSString*) text
{
    return [text boundingRectWithSize: self.accountNameLabel.frame.size
                              options: NSStringDrawingUsesLineFragmentOrigin
                           attributes: @{ NSFontAttributeName:self.accountNameLabel.font }
                              context: nil].size.width;
}


- (void) setupChangePhotoButton
{
    self.changePhotoButton = [[CHIJButton alloc] initChangePhoto];
    [self.changePhotoButton setTitle: NSLocalizedString( @"change photo", nil)
                            forState: (UIControlStateNormal)];
    [self.changePhotoButton addTarget: self
                               action: @selector(setupChangePhotoButtonAction)
                     forControlEvents: (UIControlEventTouchUpInside)];
    self.changePhotoButton.userInteractionEnabled = YES;
    [self addSubview: self.changePhotoButton];
}


- (void) setupChangePhotoButtonAction
{
    [self.delegate showChangePhotoActionSheet];
}


@end

