//
//  RPAboutBox.m
//  RP HD
//
//  Created by Giacomo Tufano on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPAboutBox.h"
#import "STKeychain/STKeychain.h"

@interface RPAboutBox ()

@end

@implementation RPAboutBox
@synthesize lVersion;

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
    self.lVersion.text = [NSString stringWithFormat:@"Version %@ (%@)", [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
}

- (void)viewDidUnload
{
    [self setLVersion:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        return YES;
    else
        return NO;
}

- (IBAction)OKPressed:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Logout:(id)sender
{
    NSError *err;
    [STKeychain deleteItemForUsername:@"cookies" andServiceName:@"RP" error:&err];
}

@end
