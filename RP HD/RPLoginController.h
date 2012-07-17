//
//  RPLoginController.h
//  RP HD
//
//  Created by Giacomo Tufano on 16/07/12.
//
//

#import <UIKit/UIKit.h>

@class RPViewController;

@interface RPLoginController : UIViewController

@property(strong, nonatomic) RPViewController *parent;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *formHeader;

- (IBAction)startPSD:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)createNew:(id)sender;

@end
