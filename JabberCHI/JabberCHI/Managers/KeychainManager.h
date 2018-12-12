//
//  KeychainManager.h
//  JabberCHI
//
//  Created by Yuri on 7/13/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

+ (instancetype) shared;

- (void)createOrUpdateItemWithUserName:(NSString *)userName andPassword:(NSString *)password;
- (void)deleteItemForUserName:(NSString *)userName;
- (NSString *)getItemForUserName:(NSString *)userName;

@end
