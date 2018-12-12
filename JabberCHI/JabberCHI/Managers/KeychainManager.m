//
//  KeychainManager.m
//  JabberCHI
//
//  Created by Yuri on 7/13/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "KeychainManager.h"

static const NSString *kBundleID = @"CHI.JabberCHI";

@implementation KeychainManager

+ (instancetype) shared
{
    static KeychainManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[KeychainManager alloc] init];
    });
    return _sharedInstance;
}

- (void)createOrUpdateItemWithUserName:(NSString *)userName andPassword:(NSString *)password
{
    //Let's create an empty mutable dictionary:
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];

    
    //Populate it with the data and the attributes we want to use.
    
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
    keychainItem[(__bridge id)kSecAttrServer] = kBundleID;
    keychainItem[(__bridge id)kSecAttrAccount] = userName;
    
    //Check if this keychain item already exists.
    
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr)
    {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The Item Already Exists", nil)
//                                                        message:NSLocalizedString(@"Please update it instead.", )
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
        
    }else
    {
        keychainItem[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding]; //Our password
        
        OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
        NSLog(@"Error Code: %d", (int)sts);
    }
}
- (void)deleteItemForUserName:(NSString *)userName
{
    
}
- (NSString *)getItemForUserName:(NSString *)userName
{
    //Let's create an empty mutable dictionary:
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    
    NSString *password;
  
    
    //Populate it with the data and the attributes we want to use.
    
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
    keychainItem[(__bridge id)kSecAttrServer] = kBundleID;
    keychainItem[(__bridge id)kSecAttrAccount] = userName;
    
    //Check if this keychain item already exists.
    
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    
    CFDictionaryRef result = nil;
    
    OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    
    NSLog(@"Error Code: %d", (int)sts);
    
    if(sts == noErr)
    {
        NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
        NSData *pswd = resultDict[(__bridge id)kSecValueData];
       password = [[NSString alloc] initWithData:pswd encoding:NSUTF8StringEncoding];

    }
    return password;
}


- (void)updateItemForUserName:(NSString *)userName andPassword:(NSString *)password
{
        //Let's create an empty mutable dictionary:
        NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];

        keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
        keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
        keychainItem[(__bridge id)kSecAttrServer] = kBundleID;
        keychainItem[(__bridge id)kSecAttrAccount] = userName;
        
        //Check if this keychain item already exists.
        
        if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr)
        {
            //The item was found.
            
            //We can update the keychain item.
            
            NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
            attributesToUpdate[(__bridge id)kSecValueData] = [password dataUsingEncoding:NSUTF8StringEncoding];
            
            OSStatus sts = SecItemUpdate((__bridge CFDictionaryRef)keychainItem, (__bridge CFDictionaryRef)attributesToUpdate);
            NSLog(@"Error Code: %d", (int)sts);
        }else
        {
            NSLog(@"Error: Can't update item in Keychain");
        }
    }
@end
