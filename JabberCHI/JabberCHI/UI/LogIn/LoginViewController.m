//
//  LoginViewController.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginView.h"
#import <Security/Security.h>
#import "JabberManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "KeychainManager.h"
#import "UIColor+JabberCHIColors.h"
#import "CHIAlertView.h"
#import <Reachability.h>

@interface LoginViewController()<LoginDelegate>

@property (nonatomic, strong) LoginView   *mainView;
@property (nonatomic, strong) UITextField *activeTextField;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation LoginViewController


- (void)loadView
{
    self.view = self.mainView;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.mainView.accountNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"];
    self.mainView.passwordTextField.text    = [[KeychainManager shared] getItemForUserName: self.mainView.accountNameTextField.text];
}


- (LoginView*) mainView
{
    if(!_mainView)
    {
        _mainView = [[LoginView alloc] initWithDelegate: self];
    }
    return _mainView;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
        
    self.title = @"Login";
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(logInSuccess)
                                                 name: @"isLoggedSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(logInFailure)
                                                 name: @"isLoggedFailure" object:nil];
    
    
}


#pragma mark -
#pragma mark - Login Delegate


- (void) logInButtonAction:(id)sender
{
    Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
    if (![internetReachable isReachable])
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showNoInternetAlert];
    }
    else
    {
    if([self checkinputFields] && [[self class] validateEmail:self.mainView.accountNameTextField.text])
    {
        self.timer= [NSTimer timerWithTimeInterval:30.0 target:self selector:@selector(logInFailure) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        
        [[JabberManager shared] connectWithJID: self.mainView.accountNameTextField.text
                                   andPassword: self.mainView.passwordTextField.text];
        
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        [self.mainView.accountNameTextField resignFirstResponder];
        [self.mainView.passwordTextField resignFirstResponder];
        
    }
    else if (![[self class] validateEmail:self.mainView.accountNameTextField.text])
    {
        CHIAlertView *validationAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Incorrect login", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
        [validationAlert show];
    }
    else if (![self validatePassword])
    {
        CHIAlertView *validationAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Password must contain from 6 to 16 characters", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
        [validationAlert show];
    }
    else
    {
        CHIAlertView *validationAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please, fill all fields", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
        [validationAlert show];
    }
    }
}


- (BOOL) checkinputFields
{
    BOOL result = YES;
    
    if(!self.mainView.accountNameTextField.text.length)
    {
        result = NO;
    }
    
    if(!self.mainView.passwordTextField.text.length)
    {
        result = NO;
    }
    
    if (!([self validatePassword]))
    {
        result = NO;
    }
    return result;
}


+ (BOOL) validateEmail: (NSString*) candidate
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat: @"SELF MATCHES[c] %@", emailRegex];
    
   if ((candidate.length) < 50)
   {
    return [emailTest evaluateWithObject: candidate];
   }
    else
    {
        return NO;
    }
}

- (BOOL) validatePassword
{
    if (self.mainView.passwordTextField.text.length <= 16 && self.mainView.passwordTextField.text.length >= 6)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) logInSuccess
{
    [self.timer invalidate];
    self.timer = nil;
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    
    [[NSUserDefaults standardUserDefaults] setObject: self.mainView.accountNameTextField.text
                                              forKey: @"LogInName"];
    [[KeychainManager shared] createOrUpdateItemWithUserName: self.mainView.accountNameTextField.text
                                                 andPassword: self.mainView.passwordTextField.text];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate showMainScreen];
}

- (void) logInFailure
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    CHIAlertView *logInAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Check login or password", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
    [logInAlert show];
    
    [self.timer invalidate];
    self.timer = nil;
}

-(BOOL)textFieldShouldBeginEditing: (UITextField *)textField
{
    textField.textColor = [UIColor loginTextFieldColor];
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField*) textField
{
    if (textField == self.mainView.accountNameTextField)
    {
        [textField setReturnKeyType: UIReturnKeyNext];
    }
    else
    {
        [textField setReturnKeyType: UIReturnKeyDone];
    }
}

- (BOOL) textFieldShouldReturn : (UITextField*) textField
{
    if (!self.activeTextField)
    {
        [self.mainView.passwordTextField becomeFirstResponder];
        self.activeTextField = self.mainView.passwordTextField;
    }
    else
    {
        [textField resignFirstResponder];
        self.activeTextField = nil;
        
        return YES;
    }
    [textField resignFirstResponder];
    
    return NO;
}


#pragma mark -
#pragma mark - KeyBoardNotifications


- (void) keyboardWillShow: (NSNotification*) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue        = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect    = [aValue   CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration: animationDuration animations: ^{
        self.mainView.keyboardOffset = keyboardRect.size.height;
        [self.mainView layoutSubviews];
    }];
}


- (void) keyboardWillHide: (NSNotification*) notification
{
    NSDictionary *userInfo          = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations: ^{
        self.mainView.keyboardOffset = 0.0f;
        [self.mainView layoutSubviews];
    }];
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end