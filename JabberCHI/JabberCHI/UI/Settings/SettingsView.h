//
//  SettingsView.h
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "BaseView.h"
#import "CHIJButton.h"
@protocol SettingsViewDelegate <NSObject, UITextFieldDelegate>


@required

-(void) logOutButtonAction:(id)sender;
-(void) showChangePhotoActionSheet;

@end


@interface SettingsView : BaseView

@property (nonatomic, strong) UIImageView *userPictureImageView;
@property (nonatomic, strong) UILabel     *accountNameLabel;
@property (nonatomic, strong) CHIJButton *changePhotoButton;
@property (nonatomic, strong) CHIJButton  *logOutButton;
@property (nonatomic, assign) CGFloat keyboardOffset;

@property (nonatomic, weak) id<SettingsViewDelegate> delegate;


//- (instancetype) initWithDelegate:(id<SettingsDelegate>) aDelegate NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithDelegate:(id<SettingsViewDelegate>) aDelegate;


@end
