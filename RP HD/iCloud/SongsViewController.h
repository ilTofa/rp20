//
//  SongsViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 03/09/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SongsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIToolbar *theToolbar;

- (IBAction)userDone:(id)sender;
- (IBAction)editTable:(id)sender;

@end
