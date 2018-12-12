//
//  ChatListViewController.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "ChatListViewController.h"
#import "XMPPUserCoreDataStorageObject.h"
#import <CoreData/CoreData.h>
#import "JabberManager.h"
#import "ChatViewController.h"
#import "ChatListView.h"
#import "CHIJContactCell.h"

@interface ChatListViewController()<NSFetchedResultsControllerDelegate, ChatListViewDelegate>

@property (nonatomic, strong) ChatListView *mainView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) NSInteger segmentedControlIndex;
@property (nonatomic, strong) NSMutableArray *unreadMessagesArray;

@end


@implementation ChatListViewController

- (void)loadView
{
    self.view = self.mainView;
    self.mainView.delegate = self;
}



- (ChatListView *)mainView
{
    if(!_mainView)
    {
        _mainView = [[ChatListView alloc] initWithDelegate: self];
    }
    
    return _mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(killFRC)
                                                 name: @"userDidLogOut" object:nil];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"";
    //[NSString stringWithFormat:NSLocalizedString(@"Yesterday you sold %@ apps", nil), @(1000000)];
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Chats", nil);
    
    // говно!!!
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.mainView.tableView.contentInset = adjustForTabbarInsets;
    self.mainView.tableView.scrollIndicatorInsets = adjustForTabbarInsets;
}

- (void) killFRC
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [self.mainView.tableView reloadData];
}

- (void) configurePhotoForCell:(CHIJContactCell*) cell
                          user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    
    if (user.photo != nil)
    {
        cell.avatarImageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[JabberManager shared] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.avatarImageView.image = [UIImage imageWithData: photoData];
        else
            cell.avatarImageView.image = [UIImage imageNamed: @"defolt_avatar"];
    }
}


#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (void)        tableView: (UITableView*)                tableView
       commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
        forRowAtIndexPath: (NSIndexPath*)                indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        
        [[JabberManager shared] deleteUser: user.jidStr];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
//{
//    NSArray *sections = [[self fetchedResultsController] sections];
//
//    if (sectionIndex < [sections count])
//    {
//        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
//
//        int section = [sectionInfo.name intValue];
//        switch (section)
//        {
//            case 0  : return @"Available";
//            case 1  : return @"Away";
//            default : return @"Offline";
//        }
//    }
//
//    return @"";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    //    NSArray *sections = [[self fetchedResultsController] sections];
    //
    //    if (sectionIndex < [sections count])
    //    {
    //        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
    //        return sectionInfo.numberOfObjects;
    //    }
    //
    //    return 0;
    
    return  self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    CHIJContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
    cell= [[CHIJContactCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier isSearch:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    XMPPUserCoreDataStorageObject *user = [[[self fetchedResultsController]fetchedObjects] objectAtIndex:indexPath.row];
    
    cell.accountNameLabel.text = user.displayName;
    cell.isOnline = user.isOnline;
    if(user.unreadMessages.boolValue)
    {
        cell.unreadMessagesCount = user.unreadMessages;
        cell.unreadLabel.hidden = NO;
    }
    else
    {
        cell.unreadMessagesCount = @(0);
        cell.unreadLabel.hidden = YES;
    }
    [self configurePhotoForCell: cell user: user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user    = [[[self fetchedResultsController]fetchedObjects] objectAtIndex:indexPath.row];
    ChatViewController *chatViewControlelr = [[ChatViewController alloc] init];
    chatViewControlelr.chatID = user.jidStr;
    chatViewControlelr.jid    = user.jid;
    chatViewControlelr.senderId = [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"];
    chatViewControlelr.senderDisplayName = user.displayName;
    user.unreadMessages = 0;
    
    chatViewControlelr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: chatViewControlelr animated: YES];
}

#pragma mark NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = [[JabberManager shared] managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum"  ascending: YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending: YES];
    
    NSArray *sortDescriptors = @[sd1, sd2];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: entity];
    [fetchRequest setSortDescriptors: sortDescriptors];
    [fetchRequest setFetchBatchSize:10];
    
    if (self.segmentedControlIndex == 1)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"sectionNum == 0"];
        [fetchRequest setPredicate: predicate];
    }
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                    managedObjectContext: moc
                                                                      sectionNameKeyPath: nil
                                                                               cacheName: nil];
    
    //    if([[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"])
    //    {
    [_fetchedResultsController setDelegate: self];
    //    }
    //    else
    //    {
    //        [_fetchedResultsController setDelegate: nil];
    //        return _fetchedResultsController;
    //    }
    
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error performing fetch: %@", error);
    }
    
    
    return _fetchedResultsController;
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.mainView.tableView reloadData];
//}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![self isViewLoaded]) return;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.mainView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.mainView.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:{

            CHIJContactCell *cell = [self.mainView.tableView cellForRowAtIndexPath:indexPath];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            XMPPUserCoreDataStorageObject *user = [[[self fetchedResultsController]fetchedObjects] objectAtIndex:indexPath.row];
            
            cell.accountNameLabel.text = user.displayName;
            cell.isOnline = user.isOnline;
            if(user.unreadMessages.boolValue)
            {
                cell.unreadMessagesCount = user.unreadMessages;
                 cell.unreadLabel.hidden = NO;
            }
            else
            {
                cell.unreadLabel.hidden = YES;
            }
            [self configurePhotoForCell: cell user: user];
//            [cell layoutSubviews];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            if (indexPath.row!=newIndexPath.row || indexPath.section!=newIndexPath.section){
                [self.mainView.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
                [self.mainView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.mainView.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
    }
}

- (void) controllerDidChangeContent: (NSFetchedResultsController*) controller {
    [self.mainView.tableView endUpdates];
}

- (void) controllerWillChangeContent: (NSFetchedResultsController*) controller {
    [self.mainView.tableView beginUpdates];
}

#pragma mark - ChatListViewDelegate

- (void) segmentedControlTabWillChange
{
    self.segmentedControlIndex = self.mainView.segmentedControl.selectedSegmentIndex;
    self.fetchedResultsController = nil;
    [self.mainView.tableView reloadData];
}

@end
