//
//  AlertManager.h
//  CommonElementsCHI
//
//  Created by iosDeveloper on 12/22/15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHIAlertView.h"

@interface AlertManager : NSObject

@property (atomic, strong) NSMutableArray *alertsArray;
@property (atomic, assign) BOOL isAlreadyShowed;

+ (AlertManager*) shared;

- (void) showAlert;

- (void) alertCallBack;

@end
