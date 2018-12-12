//
//  Chat1ViewController.m
//  JabberCHI
//
//  Created by CHI Developer on 7/29/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "ChatViewController.h"
#import <CoreData/CoreData.h>
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import <JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessages.h>
#import "UIColor+JabberCHIColors.h"
#import "UIFont+JabberCHIFonts.h"
#import "UIImage+JabberCHIImage.h"
#import <Reachability.h>
#import "macroses.h"
#import "NSData+Base64Additions.h"
#import "NSString+Contains.h"
#import "CHIAlertView.h"
#import "CHIActionSheetView.h"
#import "AppDelegate.h"

#import "PhotoMediaItem.h"


@interface ChatViewController ()
<
NSFetchedResultsControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CHIActionSheetDelegate,
UITextViewDelegate,
CHIAlertDelegate
>


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray         *messagesArray;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end


@implementation ChatViewController


- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        self.messagesArray = [NSMutableArray array];
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.senderDisplayName;
    
    [self setupJSQToolbar];
    [self setBackButton];
    [self setBlockButton];
    [self hideKeyboardWithGesture];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor: [UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor: [UIColor mainColor]];
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont proximaNovaLightWithSize: 17.0f];
    self.showLoadEarlierMessagesHeader = NO;
    [self updateFetchedResultController];
    [[[JabberManager shared] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
    
    XMPPUserCoreDataStorageObject *user = [[[JabberManager shared] xmppRosterStorage] userForJID: self.jid
                                                                                      xmppStream: [[JabberManager shared] xmppStream]
                                                                            managedObjectContext: [JabberManager shared].managedObjectContext_roster];
    user.unreadMessages = 0;
    [[[JabberManager shared] managedObjectContext_roster] save:nil];
    
}

- (void)updateFetchedResultController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context = [[XMPPMessageArchivingCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName: @"XMPPMessageArchiving_Message_CoreDataObject"
                                                     inManagedObjectContext: context];
    fetchRequest.entity = messageEntity;
    
    NSPredicate *chatNamePredicate = [NSPredicate predicateWithFormat:@"composing == NO"];
    NSPredicate *messagesPredicate = [NSPredicate predicateWithFormat: @"bareJidStr == %@", self.chatID];
    NSPredicate *mesaggeAuthorPredicate = [NSPredicate predicateWithFormat: @"streamBareJidStr == %@", [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"]];
    
    
    NSArray *subPredicates         = [NSArray arrayWithObjects: chatNamePredicate, messagesPredicate, mesaggeAuthorPredicate, nil];
    
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates: subPredicates];
    fetchRequest.predicate =  compoundPredicate;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                    managedObjectContext: context
                                                                      sectionNameKeyPath: nil
                                                                               cacheName: nil];
    _fetchedResultsController.delegate = self;
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"%@", error);
    }
    self.messagesArray = [NSMutableArray new];
    [self loadMessages];
    [self finishReceivingMessageAnimated: NO];
    
}
- (void) setupJSQToolbar
{
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage imageNamed:@"icn_camera"] forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor: [UIColor segmentedControlColor]
                                                           forState: UIControlStateNormal];
    self.inputToolbar.contentView.rightBarButtonItem.titleLabel.font = [UIFont proximaNovaBoldWithSize: 17.0f];
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"Message", nil);
    self.inputToolbar.contentView.textView.font = [UIFont proximaNovaLightWithSize: 17.0f];
    self.inputToolbar.contentView.textView.delegate = self;
}

- (void) setBackButton
{
    UIImage  *settingsImage        = [UIImage imageNamed: @"arrow_back"];
    CGRect   settingsFrame         = CGRectMake(0, 0, settingsImage.size.width + 10, settingsImage.size.height);
    UIButton *settingsButton       = [[UIButton alloc] initWithFrame: settingsFrame];
    settingsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [settingsButton  setImage: settingsImage forState: UIControlStateNormal];
    [settingsButton addTarget: self
                       action: @selector(popViewController)
             forControlEvents: UIControlEventTouchUpInside];
    
    [settingsButton setShowsTouchWhenHighlighted: YES];
    
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.leftBarButtonItem = customBarItem;
}

- (void) setBlockButton
{
    UIImage  *blockImage;
    if(![[JabberManager shared] isBlockedUser:self.jid])
    {
        blockImage        = [UIImage imageNamed: @"block_user"];
    }
    else
    {
        blockImage        = [UIImage imageNamed: @"unblock_user"];
    }
    CGRect   blockFrame         = CGRectMake(0, 0, blockImage.size.width + 10, blockImage.size.height);
    UIButton *blockButton       = [[UIButton alloc] initWithFrame: blockFrame];
    blockButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [blockButton  setImage: blockImage forState: UIControlStateNormal];
    [blockButton addTarget: self
                    action: @selector(showAskForBlockingAlert)
          forControlEvents: UIControlEventTouchUpInside];
    
    [blockButton setShowsTouchWhenHighlighted: YES];
    
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView: blockButton];
    self.navigationItem.rightBarButtonItem = customBarItem;
}

- (void) isBlocked: (BOOL)isBlocked
{
    UIImage  *blockImage;
    if(!isBlocked)
    {
        blockImage        = [UIImage imageNamed: @"block_user"];
    }
    else
    {
        blockImage        = [UIImage imageNamed: @"unblock_user"];
    }
    CGRect   blockFrame         = CGRectMake(0, 0, blockImage.size.width + 10, blockImage.size.height);
    UIButton *blockButton       = [[UIButton alloc] initWithFrame: blockFrame];
    blockButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [blockButton  setImage: blockImage forState: UIControlStateNormal];
    [blockButton addTarget: self
                    action: @selector(showAskForBlockingAlert)
          forControlEvents: UIControlEventTouchUpInside];
    
    [blockButton setShowsTouchWhenHighlighted: YES];
    
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView: blockButton];
    self.navigationItem.rightBarButtonItem = customBarItem;
}

- (void) showAskForBlockingAlert
{
    NSString *status;
    if ([[JabberManager shared] isBlockedUser:self.jid])
    {
        status = @"unblock";
    }
    else
    {
        status = @"block";
    }
    
    NSString *alertString = [NSString stringWithFormat: NSLocalizedString(@"Do you want to %@ user %@?", nil), status, [self.jid full]];
    CHIAlertView *askForBlockAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title: NSLocalizedString(@"JabMe", nil) message: alertString delegate:self cancelButtonTitle: NSLocalizedString(@"No", nil) otherButtonTitle: NSLocalizedString(@"Yes", nil)];
    [askForBlockAlert show];
}

- (void)chiAlertView:(CHIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self blockOrUnblockUser];
    }
}

- (void) blockOrUnblockUser
{
    if (![[JabberManager shared] isBlockedUser:self.jid])
    {
        NSLog(@"BLOCKED");
        [[JabberManager shared] blockUser:self.jid];
//        [self isBlocked:YES];
    }
    else
    {
        NSLog(@"UNBLOCKED");
        [[JabberManager shared] unblockUser:self.jid];
//        [self isBlocked:NO];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setBlockButton];
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue()
//                   dispatch_get_main_queue(), ^{
//        [self setBlockButton];
//    });
}

- (void) hideKeyboardWithGesture
{
    [self.collectionView addGestureRecognizer: ({
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(collectionViewTapGestureRecognizerAction:)];
        [recognizer setNumberOfTapsRequired: 1];
        [recognizer setNumberOfTouchesRequired: 1];
        recognizer;
    })];
}


- (void) collectionViewTapGestureRecognizerAction: (UIGestureRecognizer *)recognizer
{
    [self hideKeyboard];
}


- (void) hideKeyboard
{
    [self.view endEditing: YES];
}


- (void) popViewController
{
    [self.navigationController popViewControllerAnimated: YES];
}

//- (void)textViewDidChange:(UITextView *)textView
//{
//    if(textView.text.length >= 500 )
//    {
//        [self.inputToolbar toggleSendButtonEnabled];
//        CHIAlertView *textLengthAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Message must contain no more than 500 symbols", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"Ok"];
//        [textLengthAlert showInView];
//    }
//    [self.inputToolbar toggleSendButtonEnabled];
//
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length + (text.length - range.length) > 500)
    {
        CHIAlertView *textLengthAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Message must contain no more than 500 symbols", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"Ok"];
        [textLengthAlert show];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - JSQMessagesViewController method overrides


- (void) didPressSendButton: (UIButton*) button
            withMessageText: (NSString*) text
                   senderId: (NSString*) senderId
          senderDisplayName: (NSString*) senderDisplayName
                       date: (NSDate*)   date
{
    //    if (text.length > 500)
    //    {
    //        CHIAlertView *textLengthAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Message must contain no more than 500 symbols", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"Ok"];
    //        [textLengthAlert showInView];
    //    }
    
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable)
    {
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        [[JabberManager shared] sendMessage: text To: [self.jid full]];
        
        [self finishSendingMessageAnimated: YES];
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showNoInternetAlert];
    }
    
}


- (void) didPressAccessoryButton: (UIButton*) sender
{
    [self hideKeyboard];
    
    CHIActionSheetView *actionSheet = [[CHIActionSheetView alloc] initWithTitle:NSLocalizedString(@"Media messages", nil) titleColor:[UIColor mainColor] cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                              otherButtonTitles:NSLocalizedString(@"Send photo", nil), nil];
    actionSheet.delegate = self;
    
    [actionSheet show];
}

- (void)actionSheet:(CHIActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1)
    {
        return;
    }
    else
    {
        UIImagePickerController *picker;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
        {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController: picker animated: YES completion: nil];
        }
    }
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated: YES];
    
}

#pragma mark - UIImagePickerControllerDelegate


- (void) imagePickerController: (UIImagePickerController*) picker
         didFinishPickingImage: (UIImage*)                 image
                   editingInfo: (NSDictionary*)            editingInfo
{
    
    [picker dismissModalViewControllerAnimated: YES];
    
    dispatch_queue_t sendPhotoQueue = dispatch_queue_create("com.chisw.jabber.SendPhotoQueue", 0);
    dispatch_async(sendPhotoQueue, ^{
        
        
        
        // Photo encoding
        //        NSData *photoData = UIImageJPEGRepresentation(image, 1.0);
        //        NSString *photoAttachmentString = [photoData encodeBase64ForData];
        //
        //        NSXMLElement *photoAttachment = [NSXMLElement elementWithName: @"attachment"];
        //        [photoAttachment setStringValue: photoAttachmentString];
        
        // Image thumbnail encoding
        //        UIImage  *thumbnailImage = [UIImage thumbnailForImage: image];
        UIImage  *thumbnailImage = [UIImage thumbnailForImage: image];
        NSData   *thumbnailData  = UIImageJPEGRepresentation(thumbnailImage, 0.2f);
        NSString *thumbnailAttachmentString = [thumbnailData encodeBase64ForData];
        NSXMLElement *thumbnailAttachement  = [NSXMLElement elementWithName: @"thumbnail"];
        [thumbnailAttachement setStringValue: thumbnailAttachmentString];
        
        
        NSXMLElement *body = [NSXMLElement elementWithName: @"body"];
        [body setStringValue: @"image"];
        NSXMLElement *message = [NSXMLElement elementWithName: @"message"];
        [message addAttributeWithName: @"type" stringValue: @"chat"];
        [message addAttributeWithName: @"to"   stringValue: [self.jid full]];
        
        [message addChild: thumbnailAttachement];
        //        [message addChild: photoAttachment];
        [message addChild: body];
        
        NSData *string = [message.stringValue dataUsingEncoding: NSUTF8StringEncoding];
        
        NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:string.length countStyle: NSByteCountFormatterCountStyleFile]);
        
        [[[JabberManager shared] xmppStream] sendElement: message];
    });
}


#pragma mark - JSQMessages CollectionView DataSource


- (id<JSQMessageData>) collectionView: (JSQMessagesCollectionView*) collectionView
        messageDataForItemAtIndexPath: (NSIndexPath*)               indexPath
{
    return [self messageAtIndexPath: indexPath];
}

- (id<JSQMessageBubbleImageDataSource>) collectionView: (JSQMessagesCollectionView*) collectionView
              messageBubbleImageDataForItemAtIndexPath: (NSIndexPath*)               indexPath
{
    JSQMessage *message =[self messageAtIndexPath: indexPath];
    
    if ([message.senderId isEqualToString: self.senderId])
    {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>) collectionView: (JSQMessagesCollectionView*) collectionView
                     avatarImageDataForItemAtIndexPath: (NSIndexPath*) indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    JSQMessagesAvatarImage *image = nil;
    
    if (![message.senderId isEqualToString: self.senderId])
    {
        XMPPMessageArchiving_Message_CoreDataObject *messageModel = [self.fetchedResultsController.fetchedObjects objectAtIndex: indexPath.item];
        NSData *photoData = [[[JabberManager shared] xmppvCardAvatarModule] photoDataForJID: messageModel.bareJid];
        
        if (photoData)
        {
            image = [JSQMessagesAvatarImageFactory avatarImageWithImage: [UIImage imageWithData: photoData]
                                                               diameter: 45.0f];
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(45.0f, 45.0f);
        }
        else
        {
            image = [JSQMessagesAvatarImageFactory avatarImageWithImage: [UIImage imageNamed: @"defolt_avatar"]
                                                               diameter: 45.0f];
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(45.0f, 45.0f);
        }
    }
    else
    {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    return image;
}

- (NSAttributedString*)      collectionView: (JSQMessagesCollectionView*) collectionView
   attributedTextForCellTopLabelAtIndexPath: (NSIndexPath*)               indexPath
{
    JSQMessage *message = [self messageAtIndexPath:indexPath];
    NSAttributedString *formattedDate = [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate: message.date];
    
    //    if (![self isTodayMessages: message.date] && (indexPath.item == 0))
    //    {
    //        return formattedDate;
    //    }
    //    else if (![self isTodayMessages: message.date])
    //    {
    //        NSDate *currentTime = [[self.messagesArray objectAtIndex:indexPath.item] date];
    //        NSDate *lastMessageTime = [[self.messagesArray objectAtIndex:indexPath.item - 1] date];
    //
    //        double secondsInAnHour = 3600;
    //        NSTimeInterval distanceBetweenDates = ([currentTime timeIntervalSinceDate:lastMessageTime]) / secondsInAnHour;
    //        if (distanceBetweenDates > 1)
    //        {
    //            return formattedDate;
    //
    //        }
    //    }
    //
    //    return formattedDate;
    
    
    if (![self isTodayMessages: message.date] && (indexPath.item % 10) == 0)
    {
        return formattedDate;
    }
    
    return formattedDate;
}


- (NSAttributedString*)             collectionView: (JSQMessagesCollectionView*) collectionView
 attributedTextForMessageBubbleTopLabelAtIndexPath: (NSIndexPath*)               indexPath
{
    return nil;//[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}


- (NSAttributedString*)         collectionView: (JSQMessagesCollectionView*) collectionView
   attributedTextForCellBottomLabelAtIndexPath: (NSIndexPath*) indexPath
{
    JSQMessage *message = [self messageAtIndexPath: indexPath];
    if ([message.senderId isEqualToString: [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"]]
        && [self isDelivered:message])
    {
        NSDictionary *attributesArray = @{ NSForegroundColorAttributeName : [UIColor deliveredTextColor],
                                           NSFontAttributeName: [UIFont helveticaNeueCyrLightWithSize:10]};
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Delivered" attributes:attributesArray];
        NSLog(@"%@",[self messageAtIndexPath: indexPath]);
        
        return string;
    }
    else return nil;
}


#pragma mark - UICollectionView DataSource


- (NSInteger) collectionView: (UICollectionView*) collectionView
      numberOfItemsInSection: (NSInteger)         section
{
    return self.messagesArray.count;
}


- (UICollectionViewCell*) collectionView: (JSQMessagesCollectionView*) collectionView
                  cellForItemAtIndexPath: (NSIndexPath*)               indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView: collectionView
                                                                          cellForItemAtIndexPath: indexPath];
    
    JSQMessage *msg = [self messageAtIndexPath: indexPath];
    
    NSLog(@"%@", msg);
    
    if (!msg.isMediaMessage)
    {
        if (![msg.senderId isEqualToString:self.senderId])
        {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else
        {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - UICollectionView Delegate
#pragma mark - Custom menu items


- (BOOL) collectionView: (UICollectionView*) collectionView
       canPerformAction: (SEL)               action
     forItemAtIndexPath: (NSIndexPath*)      indexPath
             withSender: (id)                sender
{
    //    if (action == @selector(customAction:)) {
    //        return YES;
    //    }
    
    return [super collectionView:collectionView
                canPerformAction:action
              forItemAtIndexPath:indexPath
                      withSender:sender];
}


#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights


- (CGFloat)         collectionView: (JSQMessagesCollectionView*)           collectionView
                            layout: (JSQMessagesCollectionViewFlowLayout*) collectionViewLayout
  heightForCellTopLabelAtIndexPath: (NSIndexPath*)                         indexPath
{
    if (indexPath.item == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else
    {
        NSDate *currentTime = [[self.messagesArray objectAtIndex:indexPath.item] date];
        NSDate *lastMessageTime = [[self.messagesArray objectAtIndex:indexPath.item - 1] date];
        
        double secondsInAnHour = 3600;
        NSTimeInterval distanceBetweenDates = ([currentTime timeIntervalSinceDate:lastMessageTime]) / secondsInAnHour;
        if (distanceBetweenDates > 1)
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
            
        }
    }
    
    
    return 0.0f;
    
    
    
    
    
    //        if (indexPath.item % 10 == 0)
    //        {
    //            return kJSQMessagesCollectionViewCellLabelHeightDefault;
    //        }
    //
    //        return 0.0f;
}


- (CGFloat)                 collectionView: (JSQMessagesCollectionView*)           collectionView
                                    layout: (JSQMessagesCollectionViewFlowLayout*) collectionViewLayout
 heightForMessageBubbleTopLabelAtIndexPath: (NSIndexPath*)                         indexPath
{
    return 10.0f;//kJSQMessagesCollectionViewCellLabelHeightDefault;
}


- (CGFloat)          collectionView: (JSQMessagesCollectionView*)           collectionView
                             layout: (JSQMessagesCollectionViewFlowLayout*) collectionViewLayout
heightForCellBottomLabelAtIndexPath: (NSIndexPath*)                         indexPath
{
    if ([[[self messageAtIndexPath: indexPath] senderId] isEqualToString: [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"]] &&(indexPath.item == self.messagesArray.count - 1))
    {
        return 20.0f;
    }
    else return 0.0f;
}


#pragma mark - Responding to collection view tap events


- (void)         collectionView: (JSQMessagesCollectionView*)        collectionView
                         header: (JSQMessagesLoadEarlierHeaderView*) headerView
didTapLoadEarlierMessagesButton: (UIButton*)                         sender
{
    NSLog(@"Load earlier messages!");
}


- (void) collectionView: (JSQMessagesCollectionView*) collectionView
  didTapAvatarImageView: (UIImageView*) avatarImageView
            atIndexPath: (NSIndexPath*) indexPath
{
    NSLog(@"Tapped avatar!");
    
    [self hideKeyboard];
}


- (void)           collectionView: (JSQMessagesCollectionView*) collectionView
   didTapMessageBubbleAtIndexPath: (NSIndexPath*)               indexPath
{
    NSLog(@"Tapped message bubble!");
    
    [self hideKeyboard];
}


- (void) collectionView: (JSQMessagesCollectionView*) collectionView
  didTapCellAtIndexPath: (NSIndexPath*)               indexPath
          touchLocation: (CGPoint)                    touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    
    [self hideKeyboard];
}


#pragma mark -


- (id<JSQMessageAvatarImageDataSource>) avatarSourceForIndexPath: (NSIndexPath*) indexPath
{
    return nil;
}


- (JSQMessage*) messageAtIndexPath: (NSIndexPath*) indexPath
{
    return [self.messagesArray objectAtIndex: indexPath.item];
}


#pragma mark - FetchedResultsController



//- (void) controller: (NSFetchedResultsController*) controller
//    didChangeObject: (id)                          anObject
//        atIndexPath: (NSIndexPath *)               indexPath
//      forChangeType: (NSFetchedResultsChangeType)  type
//       newIndexPath: (NSIndexPath *)               newIndexPath
//{
//    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//    [self addMessage: anObject];
//    [self finishReceivingMessageAnimated: YES];
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            if ([[anObject messageStr] containsSecondString:@"error"])
            {
                
                NSManagedObjectContext *context = [anObject managedObjectContext];
                [context deleteObject:anObject];
                [context save:nil];
            }
            else
            {
                [self addMessage: anObject];
                [self finishReceivingMessageAnimated: YES];
            }
            break;
        }
        case NSFetchedResultsChangeDelete: {
            
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            
            break;
        }
        case NSFetchedResultsChangeMove: {
            
        }
        default:
            break;
    }
}

- (void) loadMessages
{
    for (XMPPMessageArchiving_Message_CoreDataObject *message in self.fetchedResultsController.fetchedObjects)
    {
        [self addMessage: message];
    }
}


- (void) addMessage: (XMPPMessageArchiving_Message_CoreDataObject*) message
{
    [self.messagesArray addObject: [self messageFromCoreDataModel: message]];
}


- (JSQMessage*) messageFromCoreDataModel: (XMPPMessageArchiving_Message_CoreDataObject*) model
{
    //    if ([model.messageStr containsSecondString:@"error code=\"503\""])
    
    NSString *body = model.body;
    if(!body)
    {
        body = @"";
    }
    
    NSString *senderMessageID = nil;
    
    if(model.isOutgoing)
    {
        senderMessageID = self.senderId;
    }
    else
    {
        senderMessageID = model.bareJidStr;
    }
    
    JSQMessage *message;
    
    if (![model.messageStr containsSecondString: @"<thumbnail>"])
    {
        message = [[JSQMessage alloc] initWithSenderId: senderMessageID
                                     senderDisplayName: self.senderDisplayName
                                                  date: model.timestamp
                                                  text: body];
    }
    else
    {
        PhotoMediaItem *photoMedia = [[PhotoMediaItem alloc] initWithMessageString: model.messageStr];
        
        message = [[JSQMessage alloc] initWithSenderId: senderMessageID
                                     senderDisplayName: self.senderDisplayName
                                                  date: model.timestamp
                                                 media: photoMedia];
    }
    
    return message;
}

- (BOOL) isDelivered: (JSQMessage*) message
{
    return [message.text containsSecondString:@"</recieved>"];
}


- (BOOL) isTodayMessages: (NSDate*) date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components: (NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                          fromDate: [NSDate date]];
    NSDate *today                = [cal dateFromComponents: components];
    components                   = [cal components: (NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                          fromDate: date];
    
    NSDate *otherDate = [cal dateFromComponents: components];
    
    if([today isEqualToDate: otherDate])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
