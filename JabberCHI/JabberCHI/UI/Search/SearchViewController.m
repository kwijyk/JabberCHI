//
//  SearchViewController.m
//  jabber
//
//  Created by Developer on 9/21/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "SearchViewController.h"
#import "UIColor+JabberCHIColors.h"
#import "ChatListView.h"
#import <CoreData/CoreData.h>
#import "CHIJContactCell.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "JabberManager.h"
#import "SearchView.h"
#import "LoginViewController.h"
#import "macroses.h"
#import "XMPPJID.h"
#import "CHIAlertView.h"

@interface SearchViewController ()
<
NSFetchedResultsControllerDelegate
>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) SearchView *searchView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SearchViewController

- (void)loadView
{
    self.searchView = [[SearchView alloc] initWithDelegate:self];
    self.view = self.searchView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.navigationController.navigationBar.frame.size.width,
                                                                   self.navigationController.navigationBar.frame.size.height)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.barTintColor = [UIColor mainColor];
    [self.searchBar setTintColor:[UIColor grayColor]];
    
    self.searchBar.delegate = self;
    self.searchView.tableView.tableHeaderView = self.searchBar;
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [[UIColor mainColor] CGColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"";
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Search", nil);
    
}

- (void) viewDidAppear:(BOOL)animated
{
    self.query = nil;
}

#pragma mark - Search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.query = nil;
    [self.searchView.tableView reloadData];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    if([LoginViewController validateEmail:searchBar.text])
    {
        self.query = searchBar.text;
        [self.searchView.tableView reloadData];
    }
    else
    {
        CHIAlertView *searchAlert = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Wrong username format", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
        [searchAlert show];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = nil;
    self.query = nil;
    self.searchBar.showsCancelButton = NO;
    [self.searchView.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    CHIJContactCell *cell = [[CHIJContactCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:CellIdentifier isSearch:YES];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.addUserButton.hidden = YES;
    if (self.query)
    {
        cell.accountNameLabel.text = self.query;
        cell.avatarImageView.image = [UIImage imageNamed: @"defolt_avatar"];
        cell.addUserButton.hidden = NO;
        
    }
    return cell;
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) aTableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.searchView.tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.query.length)
    {
        if ([[JabberManager shared] isUserExistsInRosterWithName:self.query])
        {
            NSString *alertString = [NSString stringWithFormat: NSLocalizedString(@"User %@ already exists in your contact list",nil), self.query];
            CHIAlertView *alertView= [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:alertString delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
            
            [alertView show];
        }
        else if ([[self.query lowercaseString] isEqualToString: [[NSUserDefaults standardUserDefaults] objectForKey:@"LogInName"]])
        {
            CHIAlertView *alertView= [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You can't add yourself", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
            
            [alertView show];
        }
        else if (self.query)
        {
            [[JabberManager shared] addNewUser:self.query];
            
            NSString *alertString = [NSString stringWithFormat: NSLocalizedString(@"User %@ is added to you contact list", nil), self.query];
            
            CHIAlertView *alertView= [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Notification", nil) message:NSLocalizedString(alertString, nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
            
            [alertView show];
            
            self.query = nil;
            self.searchBar.text = nil;
            
            [self.searchView.tableView reloadData];
        }
    }
}

@end
