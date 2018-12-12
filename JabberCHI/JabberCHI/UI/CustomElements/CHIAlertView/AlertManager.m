//
//  AlertManager.m
//  CommonElementsCHI
//
//  Created by iosDeveloper on 12/22/15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import "AlertManager.h"
#import "CHIAlertView.h"

@interface AlertManager ()

@end

@implementation AlertManager

+ (AlertManager*) shared
{
    static dispatch_once_t token;
    static AlertManager* sharedAlertManager;
    
    dispatch_once(&token, ^{
        
        sharedAlertManager = [[super alloc] init];
        sharedAlertManager.alertsArray = [[NSMutableArray alloc] init];
    });
    
    return sharedAlertManager;
}

- (void) showAlert
{
    if (!self.isAlreadyShowed)
    {
        self.isAlreadyShowed = YES;

        [self show];
    }
}
- (void) alertCallBack
{
    [self show];
}

- (void) show
{
    if (self.alertsArray.count)
    {
        CHIAlertView *currentAlert = [self.alertsArray objectAtIndex:0];
        
        [self.alertsArray  removeObjectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [currentAlert showSingleAlert];
            
        });
    }
    else
    {
        self.isAlreadyShowed = NO;
    }
}

@end
