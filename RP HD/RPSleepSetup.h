//
//  RPSleepSetup.h
//  RadioParadise
//
//  Created by Giacomo Tufano on 04/01/13.
//
//

#import <UIKit/UIKit.h>

@class RPSleepSetup;

@protocol RPSleepSetupDelegate <NSObject>
- (void)RPSleepSetupDidCancel:(RPSleepSetup *)controller;
- (void)RPSleepSetupDidSelect:(RPSleepSetup *)controller withDelay:(NSTimeInterval)sleepDelay;
@end

@interface RPSleepSetup : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *sleepAfter;

@property(weak, nonatomic) id<RPSleepSetupDelegate> delegate;

- (IBAction)doIt:(id)sender;
- (IBAction)cancel:(id)sender;

@end
