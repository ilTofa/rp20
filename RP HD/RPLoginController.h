//
//  RPLoginController.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@class RPLoginController;

@protocol RPLoginControllerDelegate <NSObject>
- (void)RPLoginControllerDidCancel:(RPLoginController *)controller;
- (void)RPLoginControllerDidSelect:(RPLoginController *)controller withCookies:(NSString *)cookiesString;
@end

@interface RPLoginController : UIViewController

@property(weak, nonatomic) id<RPLoginControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *formHeader;

- (IBAction)startPSD:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)createNew:(id)sender;

@end
