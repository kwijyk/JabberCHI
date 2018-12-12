//
//  JabberNetworkManager.h
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPPrivacy.h"

@interface JabberManager : NSObject
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving * xmppMessageArchivingModule;
    XMPPPrivacy *xmppPrivacy;
    
    NSString *password;
    
    BOOL customCertEvaluation;
    
    BOOL isXmppConnected;
    
}


@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchiving * xmppMessageArchivingModule;
@property (nonatomic, strong, readonly) XMPPPrivacy *xmppPrivacy;


+ (instancetype) shared;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (void) connect;
- (BOOL) connectWithJID:(NSString *)JID andPassword:(NSString *)aPassword;
- (void) disconnect;

- (void) sendMessage:(NSString *)textMessage To:(NSString *)receiverJID;

- (void) addNewUser: (NSString*) userName;
- (void) deleteUser: (NSString*) userName;

- (BOOL) isUserExistsInRosterWithName: (NSString*) userName;

//blocking
- (void) blockUser: (XMPPJID*) xmppJID;
- (void) unblockUser: (XMPPJID*) xmppJID;
- (BOOL) isBlockedUser: (XMPPJID*) xmppJID;
- (NSArray*) getBlockedArray;

@end
