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
@synthesize minimizerButton = _minimizerButton;
@synthesize logoImage = _logoImage;
@synthesize bitrateSelector = _bitrateSelector;
@synthesize songNameButton = _songNameButton;
@synthesize separatorImage = _separatorImage;
@synthesize iPhoneLogoImage = _iPhoneLogoImage;
@synthesize psdButton = _psdButton;
@synthesize theStreamer = _theStreamer;
@synthesize imageLoadQueue = _imageLoadQueue;
@synthesize theURL = _theURL;
@synthesize theRedirector = _theRedirector;
@synthesize theTimer = _theTimer;
@synthesize theAboutBox = _theAboutBox;
@synthesize theWebView = _theWebView;
@synthesize currentSongForumURL = _currentSongForumURL;
@synthesize interfaceState = _interfaceState;

#pragma mark -
#pragma mark HD images loading
-(void)loadNewImage:(NSTimer *)timer
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kHDImageURLURL]];
    [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         DLog(@"HD image url received %@ ", (data) ? @"successfully." : @"with errors.");
         DLog(@"received %lld bytes", res.expectedContentLength);
         if(data)
         {
             NSString *imageUrl = [[[NSString alloc]  initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             if(imageUrl)
             {
                 DLog(@"Loading HD image from: <%@>", imageUrl);
                 NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageUrl]];
                 [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
                  {
                      if(data)
                      {
                          UIImage *temp = [UIImage imageWithData:data];
                          DLog(@"hdImage is: %@", temp);
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
                 DLog(@"Got an invalid URL");
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
    
    DLog(@"Raw metadata: %@", metadata);
    DLog(@" Stream type: %@", self.theStreamer.streamContentType);
	NSArray *listItems = [metadata componentsSeparatedByString:@";"];
    NSRange range;
    for (NSString *item in listItems) {
        DLog(@"item: %@", item);
        // Look for title
        range = [item rangeOfString:@"StreamTitle="];
        if(range.location != NSNotFound)
        {
            NSString *temp = [[item substringFromIndex:range.length] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""]];
            DLog(@"Song name: %@", temp);
            self.metadataInfo.text = temp;
            // Update metadata info
            NSArray *songPieces = [temp componentsSeparatedByString:@" - "];
            if([songPieces count] == 2)
            {
                NSDictionary *mpInfo;
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"RP-meta"]];
                mpInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                          [songPieces objectAtIndex:0], MPMediaItemPropertyArtist,   
                          [songPieces objectAtIndex:1], MPMediaItemPropertyTitle,  
                          albumArt, MPMediaItemPropertyArtwork,
                          nil];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mpInfo];
                DLog(@"set MPNowPlayingInfoCenter to %@", mpInfo);
            }
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
            // Get largest image RP have (substitute /m/ with /l/ in URL ;)
            temp = [temp stringByReplacingOccurrencesOfString:@"/m/" withString:@"/l/"];
            DLog(@"URL: <%@>", temp);
            [self.imageLoadQueue cancelAllOperations];
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:temp]];
            [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
             {
                 if(data)
                 {
                     UIImage *temp = [UIImage imageWithData:data];
                     DLog(@"image is: %@", temp);
                     // Update metadata info
                     if(temp != nil)
                     {
                         MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:temp];
                         NSString *artist = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo] objectForKey:MPMediaItemPropertyArtist];
                         if(!artist)
                             artist = @"";
                         NSString *title = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo] objectForKey:MPMediaItemPropertyTitle];
                         if(!title)
                             title = @"";
                         NSDictionary *mpInfo;
                         mpInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   artist, MPMediaItemPropertyArtist,   
                                   title, MPMediaItemPropertyTitle,  
                                   albumArt, MPMediaItemPropertyArtwork,
                                   nil];
                         [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mpInfo];
                         DLog(@"set MPNowPlayingInfoCenter (with album) to %@", mpInfo);
                     }

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
	DLog(@"Stream Redirected\nOld: <%@>\nNew: %@", self.theURL, [self.theStreamer.url absoluteString]);
    self.theURL = [self.theStreamer.url absoluteString];
    [self stopPressed:nil];
    self.metadataInfo.text = @"Stream redirected, please restart...";
}

-(void)applicationChangedState:(NSNotification *)note
{
    DLog(@"applicationChangedState: %@", note.name);
    if([note.name isEqualToString:UIApplicationDidEnterBackgroundNotification])
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.theStreamer.isPlaying)
            {
                [FlurryAnalytics logEvent:@"Backgrounding while playing"];
            }
            // If we don't have a second screen...
            if ([[UIScreen screens] count] == 1)
            {
                DLog(@"No more images, please");
                [self.theTimer invalidate];
                self.theTimer = nil;
            }
        });
    if([note.name isEqualToString:UIApplicationWillEnterForegroundNotification])
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"Images again, please");
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
    // If this is a real stream connect notification set and enable stop button (on main thread)
    if(note)
    {
        DLog(@"This is stopSpinner from a real notification!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateNormal];
            [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateHighlighted];
            [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateSelected];        
            self.playOrStopButton.enabled = YES;
        });
    }
}

#pragma mark -
#pragma mark Actions

- (void)realPlay:(id)sender 
{
    [FlurryAnalytics logEvent:@"Streaming" timed:YES];
    self.theStreamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.theURL]];
    [self startSpinner];
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
    // Stop spinner will re-enable the button on stream connection
    self.minimizerButton.enabled = YES;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    [self.theStreamer start];
}

- (void)playFromRedirector
{
    DLog(@"Starting play for <%@>.", self.theRedirector);

    // Disable button
    self.playOrStopButton.enabled = NO;
    // Now search for audio redirector type of files
    NSArray *values = [NSArray arrayWithObjects:@".m3u", @".pls", @".wax", @".ram", @".pls", @".m4u", nil];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@" %@ ENDSWITH[cd] SELF ", self.theRedirector];
    NSArray * searchResults = [values filteredArrayUsingPredicate:predicate];
    // if an audio redirector is found...
    if([searchResults count] > 0)
    {
        // Now loading the redirector to find the "right" URL
        DLog(@"Loading audio redirector of type %@ from <%@>.", [searchResults objectAtIndex:0], self.theRedirector);
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.theRedirector]];
        [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
         {
             if(data)
             {
                 NSString *redirectorData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 DLog(@"Data from redirector are:\n<%@>", redirectorData);
                 // Now get the URLs
                 NSError *error = NULL;
                 NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                 NSTextCheckingResult *result = [detector firstMatchInString:redirectorData options:0 range:NSMakeRange(0, [redirectorData length])];
                 if(result && result.range.location != NSNotFound)
                 {
                     DLog(@"Found URL: %@", result.URL);                     
                     self.theURL = [result.URL absoluteString];
                     // call the play on main thread
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self realPlay:nil];
                     });
                 }
                 else
                 {
                     DLog(@"URL not found in redirector.");
                     self.playOrStopButton.enabled = NO;
                 }
             }
             else
             {
                 self.playOrStopButton.enabled = NO;
                 DLog(@"Error loading redirector: %@", [err localizedDescription]);
             }
         }];
    }
}

- (void)stopPressed:(id)sender 
{
    // Disable button
    self.playOrStopButton.enabled = NO;
    // Process stop request.
    [FlurryAnalytics endTimedEvent:@"Streaming" withParameters:nil];
    [self.theStreamer stop];
    if(self.interfaceState == kInterfaceMinimized || self.interfaceState == kInterfaceZoomed)
        [self interfaceToNormal];
    // Let's give the stream a couple seconds to really stop itself
    [self startSpinner];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.theTimer invalidate];
        self.theTimer = nil;
        [self stopSpinner:nil];
        ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = YES;
        self.hdImage.hidden = YES;
        self.rpWebButton.hidden = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamHasMetadata object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsInError object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamConnected object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsRedirected object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        self.minimizerButton.enabled = NO;
        self.theStreamer = nil;
        [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
        [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateHighlighted];
        [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateSelected];
        self.playOrStopButton.enabled = YES;
        // if called from bitrateChanged, restart
        if(sender == self)
            [self playFromRedirector]; 
    });
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
    // If needed, stop the stream
    if(self.theStreamer.isPlaying)
        [self stopPressed:self];
}

- (IBAction)presentAboutBox:(id)sender 
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(self.theAboutBox == nil)
        {
            self.theAboutBox = [[UIPopoverController alloc] initWithContentViewController:[[RPAboutBox alloc] initWithNibName:@"AboutBox" bundle:[NSBundle mainBundle]]];
            self.theAboutBox.popoverContentSize = CGSizeMake(340, 361);
        }
        [self.theAboutBox presentPopoverFromRect:self.aboutButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        RPAboutBox *theAboutBox;
        if(self.theAboutBox == nil)
        {
            theAboutBox = [[RPAboutBox alloc] initWithNibName:@"AboutBox" bundle:[NSBundle mainBundle]];
            theAboutBox.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:theAboutBox animated:YES completion:nil];
        theAboutBox = nil;
    }
}

- (IBAction)presentRPWeb:(id)sender 
{
    if(self.theWebView == nil)
    {
        self.theWebView = [[RPForumView alloc] initWithNibName:@"RPForumView" bundle:[NSBundle mainBundle]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.theWebView.modalPresentationStyle = UIModalPresentationPageSheet;
        else
            self.theWebView.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:self.theWebView animated:YES completion:nil];
    self.theWebView = nil;
}

- (IBAction)songNameOverlayButton:(id)sender 
{
    [self presentRPWeb:sender];
}

- (void) interfaceToMinimized
{
    [UIView animateWithDuration:0.5 
                     animations:^(void) {
                         self.aboutButton.alpha = /*self.logoImage.alpha =*/ self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = 0.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                             self.psdButton.alpha = 0.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             self.hdImage.frame = CGRectMake(2, 97, 1020, 574);
                             self.minimizerButton.frame = CGRectMake(2, 97, 1020, 574);
                             self.metadataInfo.frame = CGRectMake(174, 707, 830, 21);
                             self.songNameButton.frame = CGRectMake(504, 707, 500, 21);
                             self.playOrStopButton.frame = CGRectMake(10, 695, 43, 43);
                             self.separatorImage.frame = CGRectMake(0, 672, 1024, 23);
                             self.psdButton.frame = CGRectMake(80, 695, 43, 43);
                             self.logoImage.frame = CGRectMake(20, 2, 300, 94);
                         }
                         else
                         {
                             self.hdImage.frame = CGRectMake(0, 25, 480, 270);
                             self.minimizerButton.frame = CGRectMake(0, 25, 480, 270);
                             self.metadataInfo.frame = CGRectMake(98, 2, 373, 21);
                             self.songNameButton.frame = CGRectMake(98, 2, 373, 21);
                             self.playOrStopButton.frame = CGRectMake(446, 295, 25, 25);
                             self.iPhoneLogoImage.frame = CGRectMake(18, 0, 25, 25);
                         }
                     }
                     completion:^(BOOL finished) {
                         self.aboutButton.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = YES;
                         self.interfaceState = kInterfaceMinimized;
                     }];    
}

- (void) interfaceToNormal
{
    self.aboutButton.hidden = self.logoImage.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = NO;
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.aboutButton.alpha = self.logoImage.alpha = self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = 1.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                             self.psdButton.alpha = 1.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             self.hdImage.frame = CGRectMake(2, 2, 1020, 574);
                             self.minimizerButton.frame = CGRectMake(2, 2, 1020, 574);
                             self.metadataInfo.frame = CGRectMake(23, 605, 830, 21);
                             self.songNameButton.frame = CGRectMake(353, 605, 500, 21);
                             self.playOrStopButton.frame = CGRectMake(373, 651, 43, 43);
                             self.separatorImage.frame = CGRectMake(0, 577, 1024, 23);
                             self.psdButton.frame = CGRectMake(463, 651, 43, 43);
                             self.logoImage.frame = CGRectMake(20, 626, 300, 94);
                         }
                         else
                         {
                             self.hdImage.frame = CGRectMake(0, 0, 480, 270);
                             self.minimizerButton.frame = CGRectMake(0, 0, 480, 270);
                             self.metadataInfo.frame = CGRectMake(98, 16, 373, 21);
                             self.songNameButton.frame = CGRectMake(98, 16, 373, 21);
                             self.playOrStopButton.frame = CGRectMake(441, 281, 30, 30);
                             self.iPhoneLogoImage.frame = CGRectMake(9, 9, 40, 40);
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         self.interfaceState = kInterfaceNormal;                    
                     }];
}

- (void)interfaceToZoomed
{
    [UIView animateWithDuration:0.5 
                     animations:^(void) {
                         self.aboutButton.alpha = self.logoImage.alpha = self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = 0.0;
                         // 574 : 768 = 1020 : x -> x = 1020 * 768 / 574
                         self.hdImage.frame = CGRectMake(-170, 0, 1364, 768);
                         self.minimizerButton.frame = CGRectMake(-170, 0, 1364, 768);
                         self.metadataInfo.frame = CGRectMake(174, 707, 830, 21);
                         self.songNameButton.frame = CGRectMake(504, 707, 500, 21);
                         self.playOrStopButton.frame = CGRectMake(10, 695, 43, 43);
                         self.separatorImage.frame = CGRectMake(0, 672, 1024, 23);
                         self.psdButton.frame = CGRectMake(80, 695, 43, 43);
                    }
                     completion:^(BOOL finished) {
                         self.aboutButton.hidden = self.logoImage.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = YES;
                         self.logoImage.frame = CGRectMake(20, 626, 300, 94);
                         self.interfaceState = kInterfaceZoomed;
                     }];    
}

- (IBAction)minimizer:(id)sender 
{
    switch (self.interfaceState) {
        case kInterfaceNormal:
            [self interfaceToMinimized];
            break;
        case kInterfaceMinimized:
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                [self interfaceToZoomed];
            else
                [self interfaceToNormal];
            break;
        case kInterfaceZoomed:
            [self interfaceToNormal];
        default:
            DLog(@"minimizer called with self.interfaceState to %d", self.interfaceState);
            break;
    }
}

- (IBAction)startPSD:(id)sender {
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
    self.interfaceState = kInterfaceNormal;
    self.minimizerButton.enabled = NO;
    // Automagically start, as per bg request
    [self playFromRedirector];
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
    [self setMinimizerButton:nil];
    [self setLogoImage:nil];
    [self setBitrateSelector:nil];
    [self setSongNameButton:nil];
    [self setSeparatorImage:nil];
    [self setIPhoneLogoImage:nil];
    [self setPsdButton:nil];
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
    DLog(@"shouldAutorotateToInterfaceOrientation called for mainController");
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        return YES;
    else
        return NO;
}

@end
