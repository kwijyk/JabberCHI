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

#import "ImageMediaModel.h"


@interface ChatViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;


@end


@implementation ChatViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.senderDisplayName;
    
    [self setupJSQToolbar];
    [self setBackButton];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor: [UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor: [UIColor mainColor]];
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont proximaNovaLightWithSize: 17.0f];
    self.showLoadEarlierMessagesHeader = NO;
}


- (void) setupJSQToolbar
{
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    //    self.inputToolbar.contentView.leftBarButtonItem = nil;
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor: [UIColor segmentedControlColor]
                                                           forState: UIControlStateNormal];
    self.inputToolbar.contentView.rightBarButtonItem.titleLabel.font = [UIFont proximaNovaBoldWithSize: 17.0f];
    self.inputToolbar.contentView.textView.placeHolder = @"Message";
    self.inputToolbar.contentView.textView.font = [UIFont proximaNovaLightWithSize: 17.0f];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
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


- (void) popViewController
{
    [self.navigationController popViewControllerAnimated: YES];
}


#pragma mark - JSQMessagesViewController method overrides


- (void) didPressSendButton: (UIButton*) button
            withMessageText: (NSString*) text
                   senderId: (NSString*) senderId
          senderDisplayName: (NSString*) senderDisplayName
                       date: (NSDate*)   date
{
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
        if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
                                                                message: NSLocalizedString(@"No internet connection" , nil)
                                                               delegate: self
                                                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                      otherButtonTitles: @"OK", nil];
            [alertView show];
        }
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Error", nil)
                                                                           message: NSLocalizedString(@"No internet connection", nil)
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"OK", nil) style: UIAlertActionStyleDefault
                                                                  handler: ^(UIAlertAction * action) {}];
            [alert addAction: defaultAction];
            
            [self presentViewController: alert animated: YES completion: nil];
        }
    }
    
}


- (void) didPressAccessoryButton: (UIButton*) sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: @"Media messages"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: @"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar: self.inputToolbar];
}


- (void)        actionSheet: (UIActionSheet*) actionSheet
  didDismissWithButtonIndex: (NSInteger)      buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    switch (buttonIndex)
    {
        case 0:
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
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated: YES];
}


#pragma mark -
#pragma mark - UIImagePickerControllerDelegate


- (void) imagePickerController: (UIImagePickerController*) picker
         didFinishPickingImage: (UIImage*)                 image
                   editingInfo: (NSDictionary*)            editingInfo
{
    
    dispatch_queue_t sendPhotoQueue = dispatch_queue_create("com.chisw.jabber.SendPhotoQueue", 0);
    
    dispatch_async(sendPhotoQueue, ^{
        
        [picker dismissModalViewControllerAnimated: YES];
        
        
        // Photo encoding
        NSData *photoData = UIImageJPEGRepresentation(image, 1.0);
        NSString *photoAttachmentString = [photoData encodeBase64ForData];
        
        NSXMLElement *photoAttachment = [NSXMLElement elementWithName: @"attachment"];
        [photoAttachment setStringValue: photoAttachmentString];
        
        // Image thumbnail encoding
        UIImage  *thumbnailImage = [UIImage thumbnailForImage: image];
        NSData   *thumbnailData  = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
        NSString *thumbnailAttachmentString = [thumbnailData encodeBase64ForData];
        NSXMLElement *thumbnailAttachement  = [NSXMLElement elementWithName: @"thumbnail"];
        [thumbnailAttachement setStringValue: thumbnailAttachmentString];
        
        
        NSXMLElement *body = [NSXMLElement elementWithName: @"body"];
        [body setStringValue: @"image test"];
        NSXMLElement *message = [NSXMLElement elementWithName: @"message"];
        [message addAttributeWithName: @"type" stringValue: @"chat"];
        [message addAttributeWithName: @"to"   stringValue: [self.jid full]];
        
        [message addChild: thumbnailAttachement];
        [message addChild: photoAttachment];
        [message addChild: body];
        
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
                                                               diameter: 50.0f];
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(50.0f, 50.0f);
        }
        else
        {
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
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
    return nil;
}


#pragma mark - UICollectionView DataSource


- (NSInteger) collectionView: (UICollectionView*) collectionView
      numberOfItemsInSection: (NSInteger)         section
{
    return [self.fetchedResultsController.fetchedObjects count];
}


- (UICollectionViewCell*) collectionView: (JSQMessagesCollectionView*) collectionView
                  cellForItemAtIndexPath: (NSIndexPath*)               indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView: collectionView
                                                                          cellForItemAtIndexPath: indexPath];
    
    JSQMessage *msg = [self messageAtIndexPath:indexPath];
    
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
    if (indexPath.item % 10 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
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
    return 0.0f;
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
}


- (void)           collectionView: (JSQMessagesCollectionView*) collectionView
   didTapMessageBubbleAtIndexPath: (NSIndexPath*)               indexPath
{
    NSLog(@"Tapped message bubble!");
}


- (void) collectionView: (JSQMessagesCollectionView*) collectionView
  didTapCellAtIndexPath: (NSIndexPath*)               indexPath
          touchLocation: (CGPoint)                    touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


#pragma mark -


- (id<JSQMessageAvatarImageDataSource>) avatarSourceForIndexPath: (NSIndexPath*) indexPath
{
    return nil;
}


- (JSQMessage*) messageAtIndexPath: (NSIndexPath*) indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *messageModel = [self.fetchedResultsController.fetchedObjects objectAtIndex: indexPath.item];
    JSQMessage *message = [self messageFromCoreDataModel: messageModel];
    
    return message;
}


- (JSQMessage*) messageFromCoreDataModel: (XMPPMessageArchiving_Message_CoreDataObject*) model
{
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
    
    if (![model.messageStr containsString: @"<attachment>"])
    {
        message = [[JSQMessage alloc] initWithSenderId: senderMessageID
                                     senderDisplayName: self.senderDisplayName
                                                  date: model.timestamp
                                                  text: body];
    }
    else
    {
        //        ImageMediaModel *imageModel = [[ImageMediaModel alloc] initWithBase64String: model.messageStr];
        
        
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//
            NSString *attchm = [[model.messageStr componentsSeparatedByString: @"<thumbnail>"] objectAtIndex: 1];
            NSString *str    = [[attchm componentsSeparatedByString: @"</thumbnail>"] objectAtIndex: 0];
        
            NSData *base64Photo = [NSData decodeBase64ForString: str];
        UIImage *image = [UIImage imageWithData: base64Photo];
        
        JSQPhotoMediaItem *photoMedia = [[JSQPhotoMediaItem alloc] initWithImage: image];
//
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                photoMedia.image = [UIImage imageWithData: base64Photo];
//            });
//        });
        
        message = [[JSQMessage alloc] initWithSenderId: senderMessageID
                                     senderDisplayName: self.senderDisplayName
                                                  date: model.timestamp
                                                 media: photoMedia];
        NSLog(@"Перерисовую");
        
    }
    
    return message;
}


#pragma mark - FetchedResultsController


- (NSFetchedResultsController*) fetchedResultsController
{
    if (_fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSManagedObjectContext *context = [[XMPPMessageArchivingCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
        NSEntityDescription *messageEntity = [NSEntityDescription entityForName: @"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext: context];
        fetchRequest.entity = messageEntity;
        
        NSPredicate *chatNamePredicate = [NSPredicate predicateWithFormat:@"composing == NO"];
        NSPredicate *messagesPredicate = [NSPredicate predicateWithFormat: @"bareJidStr == %@", self.chatID];
        
        NSArray *subPredicates         = [NSArray arrayWithObjects: chatNamePredicate, messagesPredicate, nil];
        
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
        
    }
    
    return _fetchedResultsController;
}


- (void) controller: (NSFetchedResultsController*) controller
    didChangeObject: (id)                          anObject
        atIndexPath: (NSIndexPath *)               indexPath
      forChangeType: (NSFetchedResultsChangeType)  type
       newIndexPath: (NSIndexPath *)               newIndexPath
{
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self finishReceivingMessageAnimated: YES];
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
