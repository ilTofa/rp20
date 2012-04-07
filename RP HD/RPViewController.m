//
//  RPViewController.m
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPViewController.h"
#import "RPAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FlurryAnalytics.h"

@interface RPViewController () <UIPopoverControllerDelegate>

@end

@implementation RPViewController

@synthesize metadataInfo = _metadataInfo;
// @synthesize coverImage = _coverImage;
@synthesize playOrStopButton = _playOrStopButton;
@synthesize volumeViewContainer = _volumeViewContainer;
@synthesize spinner = _spinner;
@synthesize hdImage = _hdImage;
@synthesize aboutButton = _aboutButton;
@synthesize rpWebButton = _rpWebButton;
@synthesize theStreamer = _theStreamer;
@synthesize imageLoadQueue = _imageLoadQueue;
@synthesize theURL = _theURL;
@synthesize theRedirector = _theRedirector;
@synthesize theTimer = _theTimer;
@synthesize theAboutBox = _theAboutBox;
@synthesize theWebView = _theWebView;
@synthesize currentSongForumURL = _currentSongForumURL;

#pragma mark -
#pragma mark HD images loading
-(void)loadNewImage:(NSTimer *)timer
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kHDImageURLURL]];
    [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         NSLog(@"HD image url received %@ ", (data) ? @"successfully." : @"with errors.");
         NSLog(@"received %lld bytes", res.expectedContentLength);
         if(data)
         {
             NSString *imageUrl = [[[NSString alloc]  initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             if(imageUrl)
             {
                 NSLog(@"Loading HD image from: <%@>", imageUrl);
                 NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageUrl]];
                 [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
                  {
                      if(data)
                      {
                          UIImage *temp = [UIImage imageWithData:data];
                          NSLog(@"hdImage is: %@", temp);
                          // Protect from 404's
                          if(temp)
                          {
                              // load image on the main thread
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.hdImage setImage:temp];
                                  // If we have a second screen, update also there
                                  if ([[UIScreen screens] count] > 1)
                                      [((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).TVviewController.TVImage setImage:temp];
                              });
                          }
                      }
                  }];
             }
             else {
                 NSLog(@"Got an invalid URL");
             }
         }
     }];
}

#pragma mark -
#pragma mark AudioStream Notifications management

-(void)metadataNotificationReceived:(NSNotification *)note
{
    // Parse metadata...
    NSString *metadata = self.theStreamer.metaDataString;
    
    NSLog(@"Raw metadata: %@", metadata);
    NSLog(@" Stream type: %@", self.theStreamer.streamContentType);
	NSArray *listItems = [metadata componentsSeparatedByString:@";"];
    NSRange range;
    for (NSString *item in listItems) {
        NSLog(@"item: %@", item);
        // Look for title
        range = [item rangeOfString:@"StreamTitle="];
        if(range.location != NSNotFound)
        {
            NSString *temp = [[item substringFromIndex:range.length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""]];
            NSLog(@"Song name: %@", temp);
            self.metadataInfo.text = temp;
            // If we have a second screen, update also there
            if ([[UIScreen screens] count] > 1)
                ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).TVviewController.songNameOnTV.text = temp;
        }
        // Look for URL
        range = [item rangeOfString:@"StreamUrl="];
        if(range.location != NSNotFound)
        {
            NSString *temp = [item substringFromIndex:range.length];
            temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""]];
            NSLog(@"URL: <%@>", temp);
            [self.imageLoadQueue cancelAllOperations];
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:temp]];
            [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
             {
                 if(data)
                 {
                     UIImage *temp = [UIImage imageWithData:data];
                     NSLog(@"image is: %@", temp);
                     // load image on the main thread
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.rpWebButton setBackgroundImage:temp forState:UIControlStateNormal];
                         [self.rpWebButton setBackgroundImage:temp forState:UIControlStateHighlighted];
                         [self.rpWebButton setBackgroundImage:temp forState:UIControlStateSelected];
                     });
                 }
                 else
                 {
                     [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateNormal];
                     [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateHighlighted];
                     [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateSelected];
                 }
             }];
        }
    }
}

-(void)errorNotificationReceived:(NSNotification *)note
{
	self.metadataInfo.text = @"Stream Error, please restart...";
    [self stopPressed:nil];
}

-(void)streamRedirected:(NSNotification *)note
{
	NSLog(@"Stream Redirected\nOld: <%@>\nNew: %@", self.theURL, [self.theStreamer.url absoluteString]);
    self.theURL = [self.theStreamer.url absoluteString];
    [self stopPressed:nil];
    self.metadataInfo.text = @"Stream redirected, please restart...";
}

-(void)applicationChangedState:(NSNotification *)note
{
    NSLog(@"applicationChangedState: %@", note.name);
    if([note.name isEqualToString:UIApplicationDidEnterBackgroundNotification])
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.theStreamer.isPlaying)
            {
                [FlurryAnalytics logEvent:@"Backgrounding while playing"];
            }
            // If we don't have a second screen...
            if ([[UIScreen screens] count] == 1)
            {
                NSLog(@"No more images, please");
                [self.theTimer invalidate];
                self.theTimer = nil;
            }
        });
    if([note.name isEqualToString:UIApplicationWillEnterForegroundNotification])
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Images again, please");
            if(self.theStreamer.isPlaying)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [FlurryAnalytics logEvent:@"In Foreground while Playing"];
                    [self loadNewImage:nil];
                    self.theTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadNewImage:) userInfo:nil repeats:YES];
                });
            }
        });
}

-(void) startSpinner
{
    [self.spinner startAnimating];
    self.metadataInfo.text = @"";
}

-(void)stopSpinner:(NSNotification *)note
{
    [self.spinner stopAnimating];
    if(!note)
    {
        self.metadataInfo.text = @"";
        [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateNormal];
        [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateHighlighted];
        [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateSelected];
    }
}

#pragma mark -
#pragma mark Actions

- (void)realPlay:(id)sender 
{
    [FlurryAnalytics logEvent:@"Streaming" timed:YES];
    self.theStreamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.theURL]];
    [self startSpinner];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateSelected];
    self.rpWebButton.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataNotificationReceived:) name:kStreamHasMetadata object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorNotificationReceived:) name:kStreamIsInError object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSpinner:) name:kStreamConnected object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamRedirected:) name:kStreamIsRedirected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationChangedState:) name:UIApplicationWillEnterForegroundNotification object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationChangedState:) name:UIApplicationDidEnterBackgroundNotification object:nil]; 
    // Only if the app is active, if this is called via events there's no need to load images
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [self loadNewImage:nil];
        self.theTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadNewImage:) userInfo:nil repeats:YES];
    }
    self.hdImage.hidden = NO;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    [self.theStreamer start];
}

- (void)playFromRedirector
{
    NSLog(@"Starting play for <%@>.", self.theRedirector);

    // Now search for audio redirector type of files
    NSArray *values = [NSArray arrayWithObjects:@".m3u", @".pls", @".wax", @".ram", @".pls", @".m4u", nil];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@" %@ ENDSWITH[cd] SELF ", self.theRedirector];
    NSArray * searchResults = [values filteredArrayUsingPredicate:predicate];
    // if an audio redirector is found...
    if([searchResults count] > 0)
    {
        // Now loading the redirector to find the "right" URL
        NSLog(@"Loading audio redirector of type %@ from <%@>.", [searchResults objectAtIndex:0], self.theRedirector);
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.theRedirector]];
        [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
         {
             if(data)
             {
                 NSString *redirectorData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"Data from redirector are:\n<%@>", redirectorData);
                 // Now get the URLs
                 NSError *error = NULL;
                 NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                 NSTextCheckingResult *result = [detector firstMatchInString:redirectorData options:0 range:NSMakeRange(0, [redirectorData length])];
                 if(result && result.range.location != NSNotFound)
                 {
                     NSLog(@"Found URL: %@", result.URL);                     
                     self.theURL = [result.URL absoluteString];
                     // call the play on main thread
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self realPlay:nil];
                     });
                 }
                 else 
                     NSLog(@"URL not found in redirector.");
             }
             else 
                 NSLog(@"Error loading redirector: %@", [err localizedDescription]);
         }];
    }
}

- (void)stopPressed:(id)sender 
{
    [FlurryAnalytics endTimedEvent:@"Streaming" withParameters:nil];
    [self.theStreamer stop];
    [self.theTimer invalidate];
    self.theTimer = nil;
    [self stopSpinner:nil];
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = YES;
    self.hdImage.hidden = YES;
    self.rpWebButton.hidden = YES;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateSelected];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamHasMetadata object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsInError object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsRedirected object:nil];
    self.theStreamer = nil;
}

- (IBAction)playOrStop:(id)sender 
{
    if(self.theStreamer.isPlaying)
        [self stopPressed:nil];
    else
        [self playFromRedirector];
}

- (IBAction)bitrateChanged:(id)sender 
{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) 
    {
        case 0:
            self.theRedirector = kRPURL24K;
            [FlurryAnalytics logEvent:@"24K selected"];
            break;
        case 1:
            self.theRedirector = kRPURL64K;
            [FlurryAnalytics logEvent:@"64K selected"];
            break;
        case 2:
            self.theRedirector = kRPURL128K;
            [FlurryAnalytics logEvent:@"128K selected"];
            break;
        default:
            break;
    }
    // If needed, restart the stream
    if(self.theStreamer.isPlaying)
        [self stopPressed:nil];
    [self playFromRedirector];
}

- (IBAction)presentAboutBox:(id)sender 
{
    if(self.theAboutBox == nil)
    {
        self.theAboutBox = [[UIPopoverController alloc] initWithContentViewController:[[RPAboutBox alloc] initWithNibName:@"AboutBox" bundle:[NSBundle mainBundle]]];
        CGSize aboutSize = {340, 340};
        self.theAboutBox.popoverContentSize = aboutSize;
    }
    [self.theAboutBox presentPopoverFromRect:self.aboutButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)presentRPWeb:(id)sender 
{
    if(self.theWebView == nil)
    {
        self.theWebView = [[RPForumView alloc] initWithNibName:@"RPForumView" bundle:[NSBundle mainBundle]];
        self.theWebView.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self presentViewController:self.theWebView animated:YES completion:nil];
    self.theWebView = nil;
}

#pragma mark -
#pragma mark LoadUnload

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    // reset text
    self.metadataInfo.text = @"";
    self.rpWebButton.hidden = YES;
    self.theRedirector = kRPURL64K;
    self.hdImage.layer.cornerRadius = 8.0;
    self.hdImage.clipsToBounds = YES;
    self.rpWebButton.layer.cornerRadius = 4.0;
    self.rpWebButton.clipsToBounds = YES;
    // Add the volume (fake it on simulator)
    self.volumeViewContainer.backgroundColor = [UIColor clearColor];
    if (!TARGET_IPHONE_SIMULATOR)
    {
        MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:self.volumeViewContainer.bounds];
        [self.volumeViewContainer addSubview: myVolumeView];
        myVolumeView = nil;
    }
    else
    {
        UISlider *myVolumeView = [[UISlider alloc] initWithFrame:self.volumeViewContainer.bounds];
        myVolumeView.value = 0.5;
        [self.volumeViewContainer addSubview: myVolumeView];
        myVolumeView = nil;
    }
    self.imageLoadQueue = [[NSOperationQueue alloc] init];
}

- (void)viewDidUnload
{
    [self setMetadataInfo:nil];
    [self setSpinner:nil];
    [self setVolumeViewContainer:nil];
    [self.imageLoadQueue cancelAllOperations];
    [self setImageLoadQueue:nil];
    [self setPlayOrStopButton:nil];
    [self setHdImage:nil];
    [self setAboutButton:nil];
    [self setRpWebButton:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Multimedia Remote Control
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent 
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) 
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrStop: nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                break;
            default:
                break;
        }
    }
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation called for mainController");
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        return YES;
    else
        return NO;
}

@end
