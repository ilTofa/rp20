//
//  RPLoginController.m
//  RP HD
//
//  Created by Giacomo Tufano on 16/07/12.
//
//

#import "RPLoginController.h"

#import "RPViewController.h"

@interface RPLoginController ()

@end

@implementation RPLoginController

@synthesize parent = _parent;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
}

- (IBAction)startPSD:(id)sender
{
    
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)createNew:(id)sender
{
    
}

@end
