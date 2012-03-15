//
//  RPViewController.m
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RPViewController ()

@end

@implementation RPViewController
@synthesize metadataInfo;
@synthesize coverImage;
@synthesize playOrStopButton;
@synthesize volumeViewContainer;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setMetadataInfo:nil];
    [self setCoverImage:nil];
    [self setPlayOrStopButton:nil];
    [self setVolumeViewContainer:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)playOrStop:(id)sender {
}

- (IBAction)bitrateChanged:(id)sender {
}

- (IBAction)refreshImage:(id)sender {
}
@end
