//
//  RPAboutBox.h
//  RP HD
//
//  Created by Giacomo Tufano on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPAboutBox : UIViewController

@property (strong, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *lVersion;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *loggedUser;
@property BOOL loggedIn;

- (IBAction)OKPressed:(id)sender;
- (IBAction)Logout:(id)sender;
- (IBAction)moreInfo:(id)sender;
- (IBAction)support:(id)sender;

@end
