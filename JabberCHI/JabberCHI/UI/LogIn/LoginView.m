//
//  LoginView.m
//  JabberCHI
//
//  Created by Yuri on 7/13/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "LoginView.h"


#import "UIFont+JabberCHIFonts.h"
#import "UIColor+JabberCHIColors.h"


@interface LoginView ()


@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIView      *separatorUnderName;
@property (strong, nonatomic) UIView      *separatorUnderPass;
@property (strong, nonatomic) UILabel     *infoLabel;


@end


@implementation LoginView



- (instancetype)init
{
    self = [super init];
    if(self)
    {
        UITapGestureRecognizer  *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [self addGestureRecognizer:gestureRecognizer];
        
        UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeUpGestureRecognizer];
    }
    return self;
}

- (void)hideKeyBoard
{
    [self endEditing:YES];
}

- (instancetype) initWithDelegate: (id<LoginDelegate>) aDelegate
{
    self = [self init];
    
    if(self)
    {
        [self setupBackgroundImageView];
        [self setupLogoImageView];
        [self setupAccountNameTextFieldWithDelegate: aDelegate];
        [self setupPasswordTextField];
        [self setupLoginButton];
        [self setupInfoLabel];
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.bgImageView.frame = self.frame;
    //    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGFloat textFieldHeight = 15.0f;
    CGFloat topOffset       = 92.0f;
    CGFloat textFieldWidth  = self.frame.size.width;
    CGFloat textFieldOffset = 30.0f;
    CGFloat buttonHeight    = 40.0f;
    
    CGFloat verticalOffset  = self.frame.size.height - buttonHeight - self.keyboardOffset;
    
    BOOL isLoginButtonHidden = (verticalOffset - CGRectGetMaxY(self.passwordTextField.frame)) < 20 ? YES : NO;
    
    if (isLoginButtonHidden)
    {
        topOffset = topOffset - buttonHeight;
    }
    
    self.logoImageView.frame = CGRectMake(self.frame.size.width / 2 - [UIImage imageNamed: @"logo"].size.width / 2 - 1,
                                          topOffset,
                                          [UIImage imageNamed: @"logo"].size.width,
                                          [UIImage imageNamed: @"logo"].size.height);
    
    self.accountNameTextField.frame = CGRectMake(0,
                                                 CGRectGetMaxY(self.logoImageView.frame) + 59.5,
                                                 textFieldWidth,
                                                 textFieldHeight);
    
    self.separatorUnderName.frame = CGRectMake(self.frame.size.width / 2 - 100,
                                               CGRectGetMaxY(self.accountNameTextField.frame) + 7,
                                               200,
                                               1);
    
    self.passwordTextField.frame  = CGRectMake(0,
                                               CGRectGetMaxY(self.separatorUnderName.frame) + textFieldOffset,
                                               textFieldWidth,
                                               textFieldHeight);
    self.separatorUnderPass.frame = CGRectMake(self.frame.size.width / 2 - 100,
                                               CGRectGetMaxY(self.passwordTextField.frame) + 7,
                                               200,
                                               1);
    
    if (isLoginButtonHidden)
    {
        verticalOffset  = CGRectGetMaxY(self.separatorUnderPass.frame) + 20;
    }
    else
    {
        verticalOffset = CGRectGetMaxY(self.separatorUnderPass.frame) + 50.5;
    }
    
    self.logInButton.frame = CGRectMake(self.frame.size.width / 2 - 100,
                                        verticalOffset,
                                        200,
                                        buttonHeight);
    
    CGFloat offset = 10.0f;
    self.infoLabel.frame = CGRectMake(offset, CGRectGetMaxY(self.frame) - 30, self.frame.size.width - offset * 2, 20);
}


#pragma mark -
#pragma mark - Setup


- (void) setupLogoImageView
{
    self.logoImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    self.logoImageView.image = [UIImage imageNamed: @"logo"];
    
    [self addSubview: self.logoImageView];
}


- (void) setupBackgroundImageView
{
    self.bgImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    self.bgImageView.image = [UIImage imageNamed: @"loginBG.png"];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self addSubview: self.bgImageView];
}


- (void) setupAccountNameTextFieldWithDelegate: (id) aDelegate
{
    self.delegate = aDelegate;
    self.accountNameTextField = [[UITextField alloc] init];
    
    self.accountNameTextField.delegate        = self.delegate;
    self.accountNameTextField.textAlignment   = NSTextAlignmentCenter;
    self.accountNameTextField.font            = [UIFont helveticaNeueCyrLightWithSize: 15];
    self.accountNameTextField.backgroundColor = [UIColor clearColor];
    self.accountNameTextField.tintColor       = [UIColor loginTextFieldColor];
    self.accountNameTextField.borderStyle     = UITextBorderStyleNone;
    self.accountNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.accountNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [self setTextField: self.accountNameTextField
                 color: [UIColor loginTextFieldColor] withPlaceholder: NSLocalizedString(@"Account name",nil)];
    
    [self addSubview:self.accountNameTextField];
    
    // setup separator
    
    self.separatorUnderName = [[UIView alloc] initWithFrame: CGRectZero];
    self.separatorUnderName.backgroundColor = [UIColor loginTextFieldColor];
    
    [self addSubview: self.separatorUnderName];
    
}


- (void) setupPasswordTextField
{
    self.passwordTextField = [[UITextField alloc] init];
    
    self.passwordTextField.delegate        = self.delegate;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.textAlignment   = NSTextAlignmentCenter;
    self.passwordTextField.font            = [UIFont helveticaNeueCyrLightWithSize: 15];
    self.passwordTextField.tintColor       = [UIColor loginTextFieldColor];
    self.passwordTextField.backgroundColor = [UIColor clearColor];
    self.passwordTextField.borderStyle     = UITextBorderStyleNone;
    
    [self setTextField: self.passwordTextField
                 color: [UIColor loginTextFieldColor] withPlaceholder: NSLocalizedString(@"Password", nil)];
    
    [self addSubview:self.passwordTextField];
    
    // setup separator
    
    self.separatorUnderPass = [[UIView alloc] initWithFrame: CGRectZero];
    self.separatorUnderPass.backgroundColor = [UIColor loginTextFieldColor];
    
    [self addSubview: self.separatorUnderPass];
}


- (void) setupLoginButton
{
    self.logInButton = [[CHIJButton alloc] init];
    
    [self.logInButton setTitle: NSLocalizedString(@"Login", nil)
                      forState: UIControlStateNormal];
    
    [self.logInButton addTarget: self.delegate
                         action: @selector(logInButtonAction:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self addSubview:self.logInButton];
}

- (void) setupInfoLabel
{
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.text = NSLocalizedString(@"To use this application you should have Jabber account", nil);
    self.infoLabel.font = [UIFont helveticaNeueCyrLightWithSize: 16];
    self.infoLabel.textColor = [UIColor loginTextFieldColor];
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    
    self.infoLabel.numberOfLines = 1;
    self.infoLabel.minimumScaleFactor=0.5;
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview: self.infoLabel];
}


#pragma mark -
#pragma mark - Private


- (void) setTextField: (UITextField*) textField
                color: (UIColor*)     color
      withPlaceholder: (NSString*)    placeholder
{
    if ([textField respondsToSelector: @selector(setAttributedPlaceholder:)])
    {
        UIColor *color = [UIColor loginTextFieldColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: placeholder
                                                                          attributes: @{NSForegroundColorAttributeName: color}];
    }
    else
    {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}



@end
