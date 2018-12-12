//
//  ContactListViewController.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactsListView.h"
#import "XMPPUserCoreDataStorageObject.h"
#import <CoreData/CoreData.h>
#import "JabberManager.h"

@interface ContactListViewController()<ContactListViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) ContactsListView *mainView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ContactListViewController


- (void)loadView
{
    self.view = self.mainView;
}

- (ContactsListView *)mainView
{
    if(!_mainView)
    {
        _mainView = [[ContactsListView alloc] initWithDelegate:nil];
        _mainView.backgroundColor = [UIColor blueColor];
    }
    
    return _mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static const NSString *cellIdentifier = @"ContactsListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
    
}

#pragma mark NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[JabberManager shared] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [_fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error])
        {
//            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.mainView.tableView reloadData];
}


@end
