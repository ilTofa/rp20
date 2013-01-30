//
//  RPAboutBox.m
//  RP HD
//
//  Created by Giacomo Tufano on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPAboutBox.h"

#import "RPLoginController.h"
#import "STKeychain/STKeychain.h"

@interface RPAboutBox () <RPLoginControllerDelegate>

@property (strong, nonatomic) UIPopoverController *theLoginBox;

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

-(void)setupUI
{
    if(self.loggedIn)
    {
        [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self.logoutButton setTitle:@"Logout" forState:UIControlStateHighlighted];
        self.loggedUser.text = [NSString stringWithFormat:@"Logged in as %@", self.username];
    }
    else
    {
        self.loggedUser.text = @"Not logged in.";
        [self.logoutButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.logoutButton setTitle:@"Login" forState:UIControlStateHighlighted];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Verify if user is logged in
    self.username = nil;
    self.loggedIn = NO;
    NSError *err;
    NSString *cookieString = [STKeychain getPasswordForUsername:@"cookies" andServiceName:@"RP" error:&err];
    if(cookieString != nil)
    {   // already logged in. Get username
        self.loggedIn = YES;
        DLog(@"User is logged. Cookie string is: '%@'", cookieString);
        NSRange endUserName = [cookieString rangeOfString:@";"];
        if(endUserName.location != NSNotFound)
        {
            DLog(@"DEBUG: endUSername.location %d, .length %d", endUserName.location, endUserName.length);
            self.username = [cookieString substringWithRange:NSMakeRange(11, endUserName.location - 11)];
            DLog(@"Logged user is %@", self.username);
        }
    }
    [self setupUI];
}

- (void)viewDidUnload
{
    [self setLVersion:nil];
    [self setLogoutButton:nil];
    [self setLoggedUser:nil];
    [self setTheText:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)viewDidLayoutSubviews
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            [self.theText setFont:[UIFont systemFontOfSize:11.0]];
        else
            [self.theText setFont:[UIFont systemFontOfSize:14.0]];
    }
    [super viewDidLayoutSubviews];
}

- (IBAction)OKPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Logout:(id)sender
{
    if(self.loggedIn)
    {
        NSError *err;
        [STKeychain deleteItemForUsername:@"cookies" andServiceName:@"RP" error:&err];
        self.loggedIn = NO;
    }
    else
    {
        // Init controller and set ourself for callback
        RPLoginController * theLoginBox = [[RPLoginController alloc] initWithNibName:@"RPLoginController" bundle:[NSBundle mainBundle]];
        theLoginBox.delegate = self;
        // if iPad, embed in a popover, go modal for iPhone
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(self.theLoginBox == nil)
                self.theLoginBox = [[UIPopoverController alloc] initWithContentViewController:theLoginBox];
            self.theLoginBox.popoverContentSize = CGSizeMake(320, 207);
            [self.theLoginBox presentPopoverFromRect:self.logoutButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            theLoginBox.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:theLoginBox animated:YES completion:nil];
        }
        // Release...
        theLoginBox = nil;
    }
    [self setupUI];
}

- (void)RPLoginControllerDidCancel:(RPLoginController *)controller
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [controller dismissModalViewControllerAnimated:YES];
}

- (void)RPLoginControllerDidSelect:(RPLoginController *)controller withCookies:(NSString *)cookiesString
{
    // dismiss the popover (if needed)
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if([self.theLoginBox isPopoverVisible])
            [self.theLoginBox dismissPopoverAnimated:YES];
    }
    else // iPhone
        [controller dismissModalViewControllerAnimated:YES];
    self.loggedIn = YES;
    [self setupUI];
}

- (IBAction)moreInfo:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radioparadise.com/ios-content.php?name=About"]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)support:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radioparadise.com/ios-content.php?name=FAQ&id_cat=203#203"]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
