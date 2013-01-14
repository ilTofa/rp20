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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Verify if user is logged in
    self.username = nil;
    NSError *err;
    NSString *cookieString = [STKeychain getPasswordForUsername:@"cookies" andServiceName:@"RP" error:&err];
    if(cookieString != nil)
    {   // already logged in. Get username
        DLog(@"User is logged. Cookie string is: '%@'", cookieString); // C_username=gtufano; C_passwd=04cbb4d0ba0130b7b398dcd286a47087
        NSRange endUserName = [cookieString rangeOfString:@";"];
        if(endUserName.location != NSNotFound)
        {
            DLog(@"DEBUG: endUSername.location %d, .length %d", endUserName.location, endUserName.length);
            self.username = [cookieString substringWithRange:NSMakeRange(11, endUserName.location - 11)];
            DLog(@"Logged user is %@", self.username);
        }
    }
    if(self.username)
        self.loggedUser.text = [NSString stringWithFormat:@"Logged in as %@", self.username];
    else
    {
        self.loggedUser.text = @"Not logged in.";
        self.logoutButton.enabled = NO;
    }
}

- (void)viewDidUnload
{
    [self setLVersion:nil];
    [self setLogoutButton:nil];
    [self setLoggedUser:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)OKPressed:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Logout:(id)sender
{
    NSError *err;
    [STKeychain deleteItemForUsername:@"cookies" andServiceName:@"RP" error:&err];
    self.loggedUser.text = @"Not logged in.";
    self.logoutButton.enabled = NO;
}

- (IBAction)moreInfo:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radioparadise.com/ios-content.php?name=AppHelp"]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)support:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radioparadise.com/rp2s-content.php?name=Content&file=settings"]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
