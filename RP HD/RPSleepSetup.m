//
//  RPSleepSetup.m
//  RadioParadise
//
//  Created by Giacomo Tufano on 04/01/13.
//
//

#import "RPSleepSetup.h"

@interface RPSleepSetup ()

@end

@implementation RPSleepSetup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sleepAfter.countDownDuration = 900.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setSleepAfter:nil];
    [super viewDidUnload];
}

- (IBAction)doIt:(id)sender
{
    [self.delegate RPSleepSetupDidSelect:self withDelay:self.sleepAfter.countDownDuration];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate RPSleepSetupDidCancel:self];
}

@end
