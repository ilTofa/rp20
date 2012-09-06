//
//  SongsViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 03/09/12.
//
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

- (IBAction)userDone:(id)sender;
- (IBAction)editTable:(id)sender;

@end
