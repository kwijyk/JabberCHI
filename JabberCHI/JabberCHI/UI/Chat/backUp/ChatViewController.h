//
//  Chat1ViewController.h
//  JabberCHI
//
//  Created by CHI Developer on 7/29/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "JabberManager.h"

@interface ChatViewController : JSQMessagesViewController

@property (nonatomic, copy) NSString *chatID;
@property (nonatomic, copy) XMPPJID *jid;

@end
