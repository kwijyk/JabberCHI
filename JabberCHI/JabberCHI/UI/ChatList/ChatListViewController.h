//
//  ChatListViewController.h
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "BaseViewController.h"
#import "CHIJContactCell.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface ChatListViewController : BaseViewController

- (void) configurePhotoForCell:(CHIJContactCell*) cell
                          user:(XMPPUserCoreDataStorageObject *)user;
@end
