//
//  LoginViewController.h
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

+ (BOOL) validateEmail: (NSString*) candidate;

@end
