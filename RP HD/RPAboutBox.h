//
//  RPAboutBox.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface RPAboutBox : UIViewController

@property (strong, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *lVersion;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *loggedUser;
@property (weak, nonatomic) IBOutlet UITextView *theText;
@property BOOL loggedIn;

- (IBAction)OKPressed:(id)sender;
- (IBAction)Logout:(id)sender;
- (IBAction)moreInfo:(id)sender;
- (IBAction)support:(id)sender;

@end
