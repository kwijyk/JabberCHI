//
//  LoginView.h
//  JabberCHI
//
//  Created by Yuri on 7/13/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "SettingsView.h"
#import "CHIJButton.h"

@protocol LoginDelegate <NSObject, UITextFieldDelegate>


@required
- (void)logInButtonAction:(id)sender;


@end


@interface LoginView : BaseView


@property (nonatomic, strong) UITextField *accountNameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) CHIJButton  *logInButton;

@property (nonatomic, assign) CGFloat keyboardOffset;

@property (nonatomic, weak) id<LoginDelegate> delegate;


- (instancetype) initWithDelegate:(id<LoginDelegate>)aDelegate;


@end
