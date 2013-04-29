//
//  SongsViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SongsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIToolbar *theToolbar;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchString;
@property (nonatomic) NSInteger searchScope;

@property (strong, nonatomic) NSString *theSelectedTitle;
@property (strong, nonatomic) NSString *theSelectedArtist;
@property (strong, nonatomic) NSData *theSelectedCover;

@property (strong, nonatomic) NSURL *iTunesURL;

- (IBAction)userDone:(id)sender;
- (IBAction)editTable:(id)sender;

@end
