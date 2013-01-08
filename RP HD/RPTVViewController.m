//
//  RPTVViewController.m
//  RP HD
//
//  Created by Giacomo Tufano on 18/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPTVViewController.h"

@interface RPTVViewController ()

@end

@implementation RPTVViewController
@synthesize TVImage;
@synthesize songNameOnTV;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTVImage:nil];
    [self setSongNameOnTV:nil];
    [self setDissolveTVImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    if(interfaceOrientation == UIInterfaceOrientationPortrait)
        return YES;
    else
        return NO;
}

@end
