//
//  RPForumView.m
//  RP HD
//
//  Created by Giacomo Tufano on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPForumView.h"

#import "STKeychain.h"
#import "LocalyticsSession.h"

@interface RPForumView () <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong, readonly) UIActionSheet *pageActionSheet;

@end

@implementation RPForumView

@synthesize theWebView = _theWebView;
@synthesize goBackButton = _goBackButton;
@synthesize goForwardButton = _goForwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize actionButton = _actionButton;
@synthesize theSpinner = _theSpinner;
@synthesize pageActionSheet = _pageActionSheet;
@synthesize songId = _songId;

- (UIActionSheet *)pageActionSheet 
{    
    if(!_pageActionSheet) 
    {
        _pageActionSheet = [[UIActionSheet alloc] initWithTitle:self.theWebView.request.URL.absoluteString delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; 
        [_pageActionSheet addButtonWithTitle:NSLocalizedString(@"Copy Link", @"")];
        [_pageActionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
        [_pageActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        _pageActionSheet.cancelButtonIndex = [_pageActionSheet numberOfButtons]-1;
    }
    return _pageActionSheet;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"webloadStarted");
    [self.theSpinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"page Loaded");
    self.theWebView.hidden = NO;
    [self.theSpinner stopAnimating];
    self.goForwardButton.enabled = [self.theWebView canGoForward];
    self.goBackButton.enabled = [self.theWebView canGoBack];
}

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
    // Don't show the ugly white window... :)
    self.theWebView.hidden = YES;
    self.isForumShown = YES;
    NSError *err;
    NSString *cookieString = [STKeychain getPasswordForUsername:@"cookies" andServiceName:@"RP" error:&err];
    if(cookieString != nil)
    {   // already logged in. Get details
        NSString *username = nil;
        NSString *passwd = nil;
        DLog(@"User is logged. Cookie string is: '%@'", cookieString); // C_username=gtufano; C_passwd=04cbb4d0ba0130b7b398dcd286a47087
        NSRange endUserName = [cookieString rangeOfString:@";"];
        if(endUserName.location != NSNotFound)
        {
            DLog(@"DEBUG: endUSername.location %d, .length %d", endUserName.location, endUserName.length);
            username = [cookieString substringWithRange:NSMakeRange(11, endUserName.location - 11)];
            DLog(@"Logged user is %@", username);
            passwd = [cookieString substringWithRange:NSMakeRange(endUserName.location + 11, 32)];
            DLog(@"Logged user encoded password is %@", passwd);
        }
        if(username && passwd)
        {
            // Set cookies before loading the view...
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:@"testCookie" forKey:NSHTTPCookieName];
            [cookieProperties setObject:@"someValue123456" forKey:NSHTTPCookieValue];
            [cookieProperties setObject:@"www.radioparadise.com" forKey:NSHTTPCookieDomain];
            [cookieProperties setObject:@"www.radioparadise.com" forKey:NSHTTPCookieOriginURL];
            [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
            [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
            [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
            [cookieProperties setObject:@"C_username" forKey:NSHTTPCookieName];
            [cookieProperties setObject:username forKey:NSHTTPCookieValue];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            [cookieProperties setObject:@"C_passwd" forKey:NSHTTPCookieName];
            [cookieProperties setObject:passwd forKey:NSHTTPCookieValue];
            cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    // Now load the starting url...
    NSString *url = [NSString stringWithFormat:kRPCurrentSongForum, self.songId];
    [self.theWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]]];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ForumOpened"];
}

- (void)viewDidUnload
{
    [self setTheWebView:nil];
    [self setGoBackButton:nil];
    [self setGoForwardButton:nil];
    [self setRefreshButton:nil];
    [self setActionButton:nil];
    [self setTheSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)viewIsDone:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBackClicked:(id)sender 
{
    [self.theWebView goBack];
}

- (IBAction)goForwardClicked:(id)sender 
{
    [self.theWebView goForward];
}

- (IBAction)refreshClicked:(id)sender 
{
    [self.theWebView reload];
}

- (IBAction)actionClicked:(id)sender 
{
    [self.pageActionSheet showFromBarButtonItem:self.actionButton animated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:NSLocalizedString(@"Open in Safari", @"")])
        [[UIApplication sharedApplication] openURL:self.theWebView.request.URL];
    
    if([title isEqualToString:NSLocalizedString(@"Copy Link", @"")]) 
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.theWebView.request.URL.absoluteString;
    }
    _pageActionSheet = nil;
}

@end
