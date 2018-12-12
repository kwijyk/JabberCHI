//
//  JabberNetworkManager.m
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "JabberManager.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "CHIAlertView.h"
#import "UIColor+JabberCHIColors.h"
#import "NSString+Contains.h"
#import "XMPPStream.h"


#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

#import "KeychainManager.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface JabberManager () <XMPPPrivacyDelegate>

@end

@implementation JabberManager

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;
@synthesize xmppPrivacy;


+(instancetype)shared
{
    static JabberManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[JabberManager alloc] init];
    });
    return _sharedInstance;
    
}

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        [self setupStream];
    }
    return self;
}

- (void)dealloc
{
    [self teardownStream];
}

#pragma mark -
- (void)sendMessage:(NSString *)textMessage To:(NSString *)receiverJID
{
    if([textMessage length] > 0)
    {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:textMessage];
        
        NSString *messageID=[self.xmppStream generateUUID];
        
        NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"id" stringValue:messageID];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"from" stringValue: [xmppStream.myJID full]];
        [message addAttributeWithName:@"to" stringValue:receiverJID];
        [message addChild:body];
        
        [message addChild:request];
        
        [xmppStream sendElement:message];
        
        
        
        //        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        //        [body setStringValue:textMessage];
        //
        //        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        //        [message addAttributeWithName:@"type" stringValue:@"chat"];
        //        [message addAttributeWithName:@"to" stringValue:receiverJID];
        //        [message addChild:body];
        //
        //        [xmppStream sendElement:message];
    }
    
}

- (void) addNewUser:(NSString*) userName
{
    XMPPJID *jid = [XMPPJID jidWithString: userName];
    [xmppRoster addUser:jid withNickname:nil];
}

- (void) deleteUser:(NSString *)userName
{
    XMPPJID *jid = [XMPPJID jidWithString: userName];
    //    [xmppRoster revokePresencePermissionFromUser:jid];
    [xmppRoster removeUser:jid];
}

#pragma mark Core Data


- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    xmppStream = [[XMPPStream alloc] init];
    xmppPrivacy = [[XMPPPrivacy alloc] init];

    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    xmppRoster.autoClearAllUsersAndResources = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];    //By this line all your messages are stored in CoreData
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    xmppPrivacy.autoClearPrivacyListInfo = NO;
    xmppPrivacy.autoRetrievePrivacyListItems = YES;
    xmppPrivacy.autoRetrievePrivacyListNames = YES;
//    [xmppPrivacy setActiveListName:@"BlockedList"];

    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    [xmppPrivacy           activate:xmppStream];
    [xmppPrivacy addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [xmppPrivacy setActiveListName:@"BlockedList"];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [xmppPrivacy           deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    [xmppvCardTempModule removeDelegate:self];
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

#pragma mark - Connect/disconnect

- (void)connect
{
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts activate:self.xmppStream];
    
    NSString *name =  [[NSUserDefaults standardUserDefaults] objectForKey:@"LogInName"];
    NSString *password = [[KeychainManager shared] getItemForUserName: name];
    [self connectWithJID: name andPassword: password];
}

- (BOOL)connectWithJID:(NSString *)JID andPassword:(NSString *)aPassword{
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    //    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    //    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    NSString *myJID = JID;
    NSString *myPassword = aPassword;
    //     NSString *myJID = @"user@gmail.com/xmppframework";
    //     NSString *myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout: XMPPStreamTimeoutNone error: &error])
    {
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    
}


#pragma mark - XMPPStream Delegate


- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        //        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isLoggedSuccess" object:nil];
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isLoggedFailure" object:nil];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream: xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSInteger unreadMessagesCount = (user.unreadMessages.integerValue);
        unreadMessagesCount++;
        user.unreadMessages = @(unreadMessagesCount);
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        {
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow: localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    if ([[presence type] isEqualToString:@"subscribe"])
    {
        XMPPJID *userJID = [[presence from] bareJID];
        
        NSString *subscriptionString = [NSString stringWithFormat:NSLocalizedString (@"User %@ sent you an invitation", nil), [userJID full]];
        
        CHIAlertView *subscriptionAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title: NSLocalizedString(@"Notification", nil) message:subscriptionString cancelButtonTitle: NSLocalizedString(@"Decline", nil) otherButtonTitle:NSLocalizedString(@"Accept",nil)
                                                               withCancelActionBlock:^(id someParameter){
                                                                   
                                                                   [[[JabberManager shared] xmppRoster] rejectPresenceSubscriptionRequestFrom:userJID];
                                                                   
                                                               }
                                                                 andOtherActionBlock:^(id anotherParameter){
                                                                     
                                                                     XMPPPresence *response = [XMPPPresence presenceWithType:@"subscribed" to:userJID];
                                                                     [xmppStream sendElement:response];
                                                                     [self addNewUser: [userJID full]];
                                                                     
                                                                 }];
        
        [subscriptionAlert show];
        
        
        
        //        BOOL knownUser = [xmppRosterStorage userExistsWithJID:userJID xmppStream:xmppStream];
        //
        //        if (knownUser && [self autoAcceptKnownPresenceSubscriptionRequests])
        //        {
        // Presence subscription request from someone who's already in our roster.
        // Automatically approve.
        //
        // <presence to="bareJID" type="subscribed"/>
        
        //        XMPPPresence *response = [XMPPPresence presenceWithType:@"subscribed" to:userJID];
        //        [xmppStream sendElement:response];
        //        [self addNewUser: [userJID full]];
        //        }
        //        else
        //        {
        //            // Presence subscription request from someone who's NOT in our roster
        //
        //            [multicastDelegate xmppRoster:self didReceivePresenceSubscriptionRequest:presence];
        //        }
    }
}


- (void)xmppStream: (XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        //        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}


#pragma mark - XMPPRosterDelegate


- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

- (BOOL) isUserExistsInRosterWithName: (NSString*) userName
{
    XMPPJID *jid = [XMPPJID jidWithString: userName];
    return  [xmppRosterStorage userExistsWithJID:jid xmppStream:xmppStream];
}

#pragma mark Blocking users

- (NSArray*) getBlockedArray
{
    return [xmppPrivacy listWithName:@"BlockedList"];
}

- (void) blockUser: (XMPPJID*) xmppJID
{
    NSXMLElement *privacyElement = [XMPPPrivacy privacyItemWithType:@"jid" value: xmppJID.bare action:@"deny" order:1];
    [XMPPPrivacy blockIQs:privacyElement];
    [XMPPPrivacy blockMessages:privacyElement];
    [XMPPPrivacy blockPresenceIn:privacyElement];
    [XMPPPrivacy blockPresenceOut:privacyElement];
    NSLog(@"-------> PRIVACY ELEMENT: %@", privacyElement);
    
    NSArray *arrayPrivacy = [[NSArray alloc] initWithObjects:privacyElement, nil];
    [xmppPrivacy setListWithName:@"BlockedList" items:arrayPrivacy];
    [xmppPrivacy setActiveListName:@"BlockedList"];
}
- (void) unblockUser: (XMPPJID*) xmppJID
{
    
    NSXMLElement *privacyElement = [XMPPPrivacy privacyItemWithType:@"jid" value: xmppJID.bare action:@"allow" order:2];
    [XMPPPrivacy blockIQs:privacyElement];
    [XMPPPrivacy blockMessages:privacyElement];
    [XMPPPrivacy blockPresenceIn:privacyElement];
    [XMPPPrivacy blockPresenceOut:privacyElement];
    NSLog(@"-------> PRIVACY ELEMENT: %@", privacyElement);
    
    NSArray *arrayPrivacy = [[NSArray alloc] initWithObjects:privacyElement, nil];
    [xmppPrivacy setListWithName:@"BlockedList" items:arrayPrivacy];
    [xmppPrivacy setActiveListName:@"BlockedList"];

}

- (BOOL) isBlockedUser: (XMPPJID*) xmppJID
{
    NSArray *blockedArray = [[NSArray alloc] initWithArray:[self getBlockedArray]];
    for (int i = 0; i < blockedArray.count; i++)
    {
//        NSLog(@"%@", [[blockedArray objectAtIndex:i] attributeForName:@"value"]);
        NSString *currentUser = [[[blockedArray objectAtIndex:i] attributeForName:@"value"] stringValue];
        NSString *permission = [[[blockedArray objectAtIndex:i] attributeForName:@"action"] stringValue];

        if ([currentUser containsSecondString:xmppJID.bare] && [permission containsSecondString:@"deny"])
        {
            NSLog(@"YES");

            return YES;
            
        }
    }
    NSLog(@"NO");

    return  NO;
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceiveListNames:(NSArray *)listNames;
{
    NSLog(@"%@", listNames);
}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListNamesDueToError:(id)error
{
    NSLog(@"%@", error);
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceiveListWithName:(NSString *)name items:(NSArray *)items
{
    NSLog(@"::::::::didReceiveListWithName:::::::%@", name);

}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotReceiveListWithName:(NSString *)name error:(id)error
{
    NSLog(@"::::::::didNotReceiveListWithName:::::::%@", name);

}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didReceivePushWithListName:(NSString *)name
{
    NSLog(@"::::::::didReceivePushWithListName:::::::%@", name);

}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didSetActiveListName:(NSString *)name
{
    NSLog(@"::::::::didSetActiveListName:::::::%@", name);

}
- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotSetActiveListName:(NSString *)name error:(id)error
{
    NSLog(@"::::::::didNotSetActiveListName:::::::%@", error);

}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didSetDefaultListName:(NSString *)name
{
    NSLog(@"::::::::didSetDefaultListName:::::::%@", name);
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotSetDefaultListName:(NSString *)name error:(id)error;
{
    NSLog(@"::::::::didNotSetDefaultListName:::::::%@", error);
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didSetListWithName:(NSString *)name
{
    NSLog(@"::::::::didSetListWithName:::::::%@", name);
}

- (void)xmppPrivacy:(XMPPPrivacy *)sender didNotSetListWithName:(NSString *)name error:(id)error
{
    NSLog(@"::::::::didNotSetListWithName:::::::%@", error);
}


@end

