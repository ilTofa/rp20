//
//  RPLoginController.m
//  RP HD
//
//  Created by Giacomo Tufano on 16/07/12.
//
//

#import "RPLoginController.h"

#import "RPViewController.h"
#import "STKeychain/STKeychain.h"

@interface RPLoginController ()

@end

@implementation RPLoginController

@synthesize delegate = _delegate;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize formHeader = _formHeader;

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
    // Load saved...
    // + (NSString *)getPasswordForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError **)error;
    NSError *err;
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    if(userName)
    {
        self.usernameField.text = userName;
        NSString *password = [STKeychain getPasswordForUsername:userName andServiceName:@"RP" error:&err];
        if(password)
            self.passwordField.text = password;
    }
    [self.usernameField becomeFirstResponder];
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
    [self setFormHeader:nil];
    [super viewDidUnload];
}

- (IBAction)startPSD:(id)sender
{
    // Try to login to RP
    NSString *temp = [NSString stringWithFormat:@"http://www.radioparadise.com/ajax_login.php?username=%@&passwd=%@", self.usernameField.text, self.passwordField.text];
    DLog(@"Logging in with <%@>", temp);
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:temp]];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         // Login is successful if data is not nil and data is not "invalid login"
         NSString *retValue = nil;
         if(data)
             retValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         BOOL invalidLogin = [retValue rangeOfString:@"invalid "].location != NSNotFound;
         if(retValue && !invalidLogin)
         { // If login successful, save info and send information to parent
             DLog(@"Login to RP is successful");
             retValue = [retValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
             NSArray *values = [retValue componentsSeparatedByString:@"|"];
             if([values count] != 2)
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.formHeader.text = @"Network error in login, please retry later.";
                     self.formHeader.textColor = [UIColor redColor];
                 });                
             NSString *cookieString = [NSString stringWithFormat:@"C_username=%@; C_passwd=%@", [values objectAtIndex:0], [values objectAtIndex:1]];
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSError *err;
                 [[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"userName"];
                 [STKeychain storeUsername:self.usernameField.text andPassword:self.passwordField.text forServiceName:@"RP" updateExisting:YES error:&err];
                 self.formHeader.text = @"Enter your Radio Paradise login";
                 self.formHeader.textColor = [UIColor whiteColor];
                 [self.delegate RPLoginControllerDidSelect:self withCookies:cookieString];
             });
         }
         else
         { // If not, notify the user (on main thread)
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.formHeader.text = @"Invalid login, please retry";
                 self.formHeader.textColor = [UIColor redColor];
             });
         }
     }];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate RPLoginControllerDidCancel:self];
}

- (IBAction)createNew:(id)sender
{
    // Send user to RP mobile registering form <http://www.radioparadise.com/m-content.php?name=Members&file=register>
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.radioparadise.com/m-content.php?name=Members&file=register"]];
    [self.delegate RPLoginControllerDidCancel:self];
}

@end
