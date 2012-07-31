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

@interface RPViewController () <UIPopoverControllerDelegate, RPLoginControllerDelegate>

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
@synthesize theImagesTimer = _theTimer;
@synthesize thePsdTimer = _thePsdTimer;
@synthesize theAboutBox = _theAboutBox;
@synthesize theWebView = _theWebView;
@synthesize currentSongForumURL = _currentSongForumURL;
@synthesize interfaceState = _interfaceState;
@synthesize isPSDPlaying = _isLoggedIn;
@synthesize cookieString = _cookieString;
@synthesize psdSongId = _psdSongId;
@synthesize thePsdStreamer = _thePsdStreamer;
@synthesize theOldPsdStreamer = _theOldPsdStreamer;
@synthesize psdDurationInSeconds = _psdDurationInSeconds;

#pragma mark -
#pragma mark HD images loading

-(void)scheduleImagesTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadNewImage:nil];
        NSTimeInterval howMuchTimeBetweenImages;
        switch (self.bitrateSelector.selectedSegmentIndex) {
            case 0:
                howMuchTimeBetweenImages = 60.0;
                break;
            case 1:
                howMuchTimeBetweenImages = 40.0;
                break;
            case 2:
                howMuchTimeBetweenImages = 20.0;
                break;
            default:
                break;
        }
        self.theImagesTimer = [NSTimer scheduledTimerWithTimeInterval:howMuchTimeBetweenImages target:self selector:@selector(loadNewImage:) userInfo:nil repeats:YES];
        DLog(@"Scheduling images timer (%@) setup to %f.0 seconds", self.theImagesTimer, howMuchTimeBetweenImages);
    });
}

-(void)unscheduleImagesTimer
{
    DLog(@"Unscheduling images timer (%@)", self.theImagesTimer);
    [self.theImagesTimer invalidate];
    self.theImagesTimer = nil;
}

-(void)loadNewImage:(NSTimer *)timer
{
    NSMutableURLRequest *req;
    if(self.isPSDPlaying)
    {
        DLog(@"Requesting PSD image");
        req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kHDImagePSDURL]];
        [req addValue:self.cookieString forHTTPHeaderField:@"Cookie"];
    }
    else
    {
        req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kHDImageURLURL]];
    }
    [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         DLog(@"HD image url received %@ ", (data) ? @"successfully." : @"with errors.");
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

-(void)PSDMetatadaHandler
{
    // This function get metadata directly in case of PSD (no stream metadata)
    // Get song name first
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.radioparadise.com/ajax_rp2_playlist_ipad.php"]];
    [req addValue:self.cookieString forHTTPHeaderField:@"Cookie"];
    [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         DLog(@"metadata received %@ ", (data) ? @"successfully." : @"with errors.");
         if(data)
         {
             // Get name and massage it (it's web encoded and with triling spaces)
             NSString *stringData = [[NSString alloc]  initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding];
             NSArray *values = [stringData componentsSeparatedByString:@"|"];
             if([values count] != 4)
             {
                 NSLog(@"Error in reading metadata from http://www.radioparadise.com/ajax_rp2_playlist_ipad.php: <%@> received.", stringData);
                 return;
             }
             NSString *metaText = [values objectAtIndex:0];
             metaText = [metaText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             metaText = [metaText stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"-"];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.metadataInfo.text = metaText;
                 // If we have a second screen, update also there
                 if ([[UIScreen screens] count] > 1)
                     ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).TVviewController.songNameOnTV.text = metaText;
                 // Update metadata info
                 NSArray *songPieces = [metaText componentsSeparatedByString:@" - "];
                 if([songPieces count] == 2)
                 {
                     NSDictionary *mpInfo;
                     MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"RP-meta"]];
                     mpInfo = @{MPMediaItemPropertyArtist: [songPieces objectAtIndex:0],
                               MPMediaItemPropertyTitle: [songPieces objectAtIndex:1],
                               MPMediaItemPropertyArtwork: albumArt};
                     [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mpInfo];
                     DLog(@"set MPNowPlayingInfoCenter to %@", mpInfo);
                 }
             });
             // remembering songid for forum view
             self.psdSongId = [values objectAtIndex:1];
             // Now get almbum artwork
             NSString *temp = [NSString stringWithFormat:@"http://www.radioparadise.com/graphics/covers/l/%@.jpg", [values objectAtIndex:3]];
             DLog(@"URL for PSD Artwork: <%@>", temp);
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
                          dispatch_async(dispatch_get_main_queue(), ^{
                              NSDictionary *mpInfo;
                              mpInfo = @{MPMediaItemPropertyArtist: artist,
                                        MPMediaItemPropertyTitle: title,
                                        MPMediaItemPropertyArtwork: albumArt};
                              [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mpInfo];
                              DLog(@"set MPNowPlayingInfoCenter (with album) to %@", mpInfo);
                              // load image on the main thread
                              [self.rpWebButton setBackgroundImage:temp forState:UIControlStateNormal];
                              [self.rpWebButton setBackgroundImage:temp forState:UIControlStateHighlighted];
                              [self.rpWebButton setBackgroundImage:temp forState:UIControlStateSelected];
                          });
                      }
                  }
                  else
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateNormal];
                          [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateHighlighted];
                          [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateSelected];
                      });
                 }
              }];
         }
     }];
}

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
                mpInfo = @{MPMediaItemPropertyArtist: [songPieces objectAtIndex:0],   
                          MPMediaItemPropertyTitle: [songPieces objectAtIndex:1],  
                          MPMediaItemPropertyArtwork: albumArt};
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
                         mpInfo = @{MPMediaItemPropertyArtist: artist,   
                                   MPMediaItemPropertyTitle: title,  
                                   MPMediaItemPropertyArtwork: albumArt};
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

-(void)tvExternalScreenInited:(NSNotification *)note
{
    // copy metadata and current HD image
    if ([[UIScreen screens] count] > 1)
    {
        ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).TVviewController.songNameOnTV.text = self.metadataInfo.text;
        [((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).TVviewController.TVImage setImage:self.hdImage.image];
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

-(void)streamConnected:(NSNotification *)note
{
    DLog(@"Stream is connected.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self interfacePlay];
    });
}

#pragma mark -
#pragma mark Actions

- (void)realPlay:(id)sender
{
    [FlurryAnalytics logEvent:@"Streaming" timed:YES];
    [self interfacePlayPending];
    self.theStreamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.theURL]];
    [self activateNotifications];
    [self.theStreamer start];
}

- (void)playFromRedirector
{
    DLog(@"Starting play for <%@>.", self.theRedirector);
    [self interfacePlayPending];

    // Now search for audio redirector type of files
    NSArray *values = @[@".m3u", @".pls", @".wax", @".ram", @".pls", @".m4u"];
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
                     [self interfaceStop];
                 }
             }
             else
             {
                 [self interfaceStop];
                 DLog(@"Error loading redirector: %@", [err localizedDescription]);
             }
         }];
    }
}

-(void)stopPsdFromTimer:(NSTimer *)aTimer
{
    DLog(@"This is the PSD timer triggering the end of the PSD song");
    // If still playing PSD, restart "normal" stream
    if(self.isPSDPlaying)
    {
        [self interfacePlayPending];
        self.isPSDPlaying = NO;
        if(self.thePsdTimer)
        {
            [self.thePsdTimer invalidate];
            self.thePsdTimer = nil;
        }
        DLog(@"Stopping stream in timer firing");
        [self unscheduleImagesTimer];
        // restart main stream...
        [self realPlay:nil];
        // ...while giving the delay to the fading
        [self.thePsdStreamer removeObserver:self forKeyPath:@"status"];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kPsdFadeOutTime * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            DLog(@"PSD stream now stopped!");
            [self.thePsdStreamer pause];
            self.thePsdStreamer = nil;
        });
    }
}

// Here PSD streaming is ready to start (and it is started)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.thePsdStreamer && [keyPath isEqualToString:@"status"])
    {
        if (self.thePsdStreamer.status == AVPlayerStatusReadyToPlay)
        {
            DLog(@"psdStreamer is ReadyToPlay for %@ secs", self.psdDurationInSeconds);
            // Prepare stop and restart stream after the claimed lenght (minus kPsdFadeOutTime seconds to allow for some fading)...
            if(self.thePsdTimer)
            {
                [self.thePsdTimer invalidate];
                self.thePsdTimer = nil;
            }
            DLog(@"We'll stop PSD automagically after %@ secs", self.psdDurationInSeconds);
            self.thePsdTimer = [NSTimer scheduledTimerWithTimeInterval:[self.psdDurationInSeconds doubleValue] target:self selector:@selector(stopPsdFromTimer:) userInfo:nil repeats:NO];
            [self.thePsdStreamer play];
            // Stop main streamer and reset timers it.
            [self unscheduleImagesTimer];
            [self removeNotifications];
            if(self.isPSDPlaying)
            {
                [self.theOldPsdStreamer pause];
                self.theOldPsdStreamer = nil;
            }
            else
            {
                [self.theStreamer stop];
                self.theStreamer = nil;
                self.isPSDPlaying = YES;
            }
            [self interfacePsd];
        }
        else if (self.thePsdStreamer.status == AVPlayerStatusFailed)
        {
            // something went wrong. player.error should contain some information
            DLog(@"Error starting PSD streamer: %@", self.thePsdStreamer.error);
            self.thePsdStreamer = nil;
            [self playFromRedirector];
        }
        else if (self.thePsdStreamer.status == AVPlayerStatusUnknown)
        {
            // something went wrong. player.error should contain some information
            DLog(@"AVPlayerStatusUnknown");
        }
        else
        {
            DLog(@"Unknown status received: %d", self.thePsdStreamer.status);
        }
    }
    else
    {
        DLog(@"Something else called observeValueForKeyPath. KeyPath is %@", keyPath);
    }
}

- (void)playPSDNow
{
    DLog(@"playPSDNow called. Cookie is <%@>", self.cookieString);
    [self interfacePsdPending];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.radioparadise.com/ajax_replace.php?option=0"]];
    [req addValue:self.cookieString forHTTPHeaderField:@"Cookie"];
    [NSURLConnection sendAsynchronousRequest:req queue:self.imageLoadQueue completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         if(data)
         {
             NSString *retValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             retValue = [retValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
             NSArray *values = [retValue componentsSeparatedByString:@"|"];
             if([values count] != 4)
             {
                 NSLog(@"ERROR: too many values (%d) returned from ajax_replace", [values count]);
                 NSLog(@"retValue: <%@>", retValue);
                 [self playFromRedirector];
                 return;
             }
             NSString *psdSongUrl = [values objectAtIndex:0];
             NSNumber *psdSongLenght = [values objectAtIndex:1];
             NSNumber *psdSongFadeIn = [values objectAtIndex:2];
             NSNumber *psdSongFadeOut = [values objectAtIndex:3];
             DLog(@"Got PSD song information: <%@>, should run for %@ ms, with fade-in, fade-out for %@ and %@", psdSongUrl, psdSongLenght, psdSongFadeIn, psdSongFadeOut);
             [FlurryAnalytics logEvent:@"PSD triggered"];
             // reset stream on main thread
             dispatch_async(dispatch_get_main_queue(), ^{
                 // If PSD is already running...
                 if(self.isPSDPlaying)
                 {
                     self.theOldPsdStreamer = self.thePsdStreamer;
                     [self.thePsdStreamer removeObserver:self forKeyPath:@"status"];
                 }
                 // Begin buffering...
                 self.thePsdStreamer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:psdSongUrl]];
                 // Add observer for real start and stop.
                 self.psdDurationInSeconds = @(([psdSongLenght doubleValue] / 1000.0) - kPsdFadeOutTime);
                 [self.thePsdStreamer addObserver:self forKeyPath:@"status" options:0 context:nil];
             });
         }
         else // we have an error in PSD processing, (re)start main stream)
         {
             [self playFromRedirector];
         }
     }];
}

- (void)stopPressed:(id)sender
{
    if(self.isPSDPlaying)
    {
        // If PSD is running, simply get back to the main stream by firing the end timer...
        DLog(@"Manually firing the PSD timer");
        [self.thePsdTimer fire];
    }
    else
    {
        [self interfaceStopPending];
        [FlurryAnalytics endTimedEvent:@"Streaming" withParameters:nil];
        // Process stop request.
        [self.theStreamer stop];
        // Let's give the stream a couple seconds to really stop itself
        double delayInSeconds = 1.0;    //was 2.0: MONITOR!
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self removeNotifications];
            [self unscheduleImagesTimer];
            self.theStreamer = nil;
            [self interfaceStop];
            // if called from bitrateChanged, restart
            if(sender == self)
                [self playFromRedirector];
        });
    }
}

- (IBAction)playOrStop:(id)sender
{
    if(self.theStreamer.isPlaying || self.isPSDPlaying)
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

- (IBAction)startPSD:(id)sender
{
    if(self.cookieString == nil)
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
           [self.theLoginBox presentPopoverFromRect:self.psdButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            theLoginBox.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:theLoginBox animated:YES completion:nil];
        }
        // Release...
        theLoginBox = nil;
    }
    else // already logged in. no need to show the login box
    {
        [self playPSDNow];
    }
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
    self.cookieString = cookiesString;
    [self playPSDNow];
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
    if(self.isPSDPlaying)
        self.theWebView.songId = self.psdSongId;
    else
        self.theWebView.songId = @"now";
    [self presentViewController:self.theWebView animated:YES completion:nil];
    self.theWebView = nil;
}

- (IBAction)songNameOverlayButton:(id)sender 
{
    [self presentRPWeb:sender];
}

#pragma mark -
#pragma mark Interface setup

-(void)activateNotifications
{
    DLog(@"*** activateNotifications");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataNotificationReceived:) name:kStreamHasMetadata object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorNotificationReceived:) name:kStreamIsInError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamConnected:) name:kStreamConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamRedirected:) name:kStreamIsRedirected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tvExternalScreenInited:) name:kTVInited object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationChangedState:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationChangedState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)removeNotifications
{
    DLog(@"*** removeNotifications");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamHasMetadata object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsInError object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStreamIsRedirected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTVInited object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)interfaceStop
{
    DLog(@"*** interfaceStop");
    if(self.interfaceState == kInterfaceMinimized || self.interfaceState == kInterfaceZoomed)
        [self interfaceToNormal];
    self.metadataInfo.text = @"";
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-play"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateSelected];
    self.psdButton.enabled = YES;
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateNormal];
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateHighlighted];
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateSelected];
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = YES;
    self.hdImage.hidden = YES;
    self.rpWebButton.hidden = YES;
    self.rpWebButton.enabled = NO;
    self.minimizerButton.enabled = NO;
    [self.spinner stopAnimating];
}

-(void)interfaceStopPending
{
    DLog(@"*** interfaceStopPending");
    [self.spinner startAnimating];
    if(self.interfaceState == kInterfaceMinimized || self.interfaceState == kInterfaceZoomed)
        [self interfaceToNormal];
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.rpWebButton.enabled = NO;
    self.minimizerButton.enabled = NO;
}

-(void)interfacePlay
{
    DLog(@"*** interfacePlay");
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-stop"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd"] forState:UIControlStateSelected];
    self.psdButton.enabled = YES;
    self.minimizerButton.enabled = YES;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    self.rpWebButton.hidden = NO;
    self.rpWebButton.enabled = YES;
    self.hdImage.hidden = NO;
    [self.spinner stopAnimating];
    // Only if the app is active, if this is called via events there's no need to load images
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        [self scheduleImagesTimer];
    // Setup PSD metadata, if needed.
    if(self.isPSDPlaying)
    {
        DLog(@"Getting PSD metadata...");
        [self PSDMetatadaHandler];
    }
}

-(void)interfacePlayPending
{
    DLog(@"*** interfacePlayPending");
    [self.spinner startAnimating];
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.rpWebButton.enabled = NO;
    self.rpWebButton.hidden = NO;
    self.minimizerButton.enabled = NO;
    self.hdImage.hidden = NO;
}

-(void)interfacePsd
{
    DLog(@"*** interfacePsd");
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = NO;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-left"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-left"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"button-left"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd-active"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd-active"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"button-psd-active"] forState:UIControlStateSelected];
    self.psdButton.enabled = YES;
    self.rpWebButton.enabled = YES;
    self.rpWebButton.hidden = NO;
    self.minimizerButton.enabled = YES;
    self.hdImage.hidden = NO;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    [self.spinner stopAnimating];
    // Only if the app is active, if this is called via events there's no need to load images
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        [self scheduleImagesTimer];
    // Setup PSD metadata, if needed.
    if(self.isPSDPlaying)
    {
        DLog(@"Getting PSD metadata...");
        [self PSDMetatadaHandler];
    }
}

-(void)interfacePsdPending
{
    DLog(@"*** interfacePsdPending");
    [self.spinner startAnimating];
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.rpWebButton.enabled = NO;
    self.rpWebButton.hidden = NO;
    self.minimizerButton.enabled = NO;
    self.hdImage.hidden = NO;
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
    // Set PSD to not logged, not playing
    self.cookieString = nil;
    self.isPSDPlaying = NO;
    // Automagically start, as per bg request
    [self playFromRedirector];
    // We would like to receive starts and stops
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
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
    [self setThePsdStreamer:nil];
    [self setTheOldPsdStreamer:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Multimedia Remote Control

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
                [self unscheduleImagesTimer];
            }
            // We would like to receive starts and stops
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [self becomeFirstResponder];
        });
    if([note.name isEqualToString:UIApplicationWillEnterForegroundNotification])
        dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"Images again, please");
            if(self.theStreamer.isPlaying)
            {
                [FlurryAnalytics logEvent:@"In Foreground while Playing"];
                [self scheduleImagesTimer];
            }
            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            [self resignFirstResponder];
        });
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent
{
    DLog(@"Remote control received");
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
