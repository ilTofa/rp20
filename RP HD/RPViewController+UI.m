//
//  RPViewController+UI.m
//  RadioParadise
//
//  Created by Giacomo Tufano on 14/01/13.
//
//

#import "RPViewController+UI.h"

#import "RPViewController.h"
#import "RPAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RPViewController (UI)

-(void)interfaceStop
{
    DLog(@"*** interfaceStop");
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if(self.interfaceState == kInterfaceMinimized || self.interfaceState == kInterfaceZoomed)
        [self interfaceToNormal];
    self.metadataInfo.text = self.rawMetadataString = @"";
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-play"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-play"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-play"] forState:UIControlStateSelected];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateSelected];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-songlist"] forState:UIControlStateNormal];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-songlist"] forState:UIControlStateHighlighted];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-songlist"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateNormal];
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateHighlighted];
    [self.rpWebButton setBackgroundImage:[UIImage imageNamed:@"RP-meta"] forState:UIControlStateSelected];
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = YES;
    self.hdImage.hidden = self.dissolveHdImage.hidden = YES;
    self.rpWebButton.hidden = YES;
    self.rpWebButton.enabled = NO;
    self.minimizerButton.enabled = NO;
    self.songInfoButton.enabled = NO;
    self.lyricsButton.enabled = NO;
    self.songIsAlreadySaved = YES;
    if(self.isLyricsToBeShown)
        [self showLyrics:nil];
    self.coverImageView.image = nil;
    if(self.theStreamMetadataTimer != nil)
    {
        [self.theStreamMetadataTimer invalidate];
        self.theStreamMetadataTimer = nil;
    }
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
    self.songInfoButton.enabled = NO;
    self.lyricsButton.enabled = NO;
    if(self.isLyricsToBeShown)
        [self showLyrics:nil];
}

-(void)interfacePlay
{
    DLog(@"*** interfacePlay");
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-stop"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-stop"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-stop"] forState:UIControlStateSelected];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd"] forState:UIControlStateSelected];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateNormal];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateHighlighted];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
    if(self.viewIsLandscape)
        self.minimizerButton.enabled = YES;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    self.rpWebButton.hidden = NO;
    self.rpWebButton.enabled = YES;
    self.songInfoButton.enabled = YES;
    self.hdImage.hidden = NO;
    self.lyricsButton.enabled = YES;
    self.songIsAlreadySaved = NO;
    [self.spinner stopAnimating];
    // Only if the app is active and is landscape or iPad or remote screen active. otherwise there's no need to load images
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive && (self.viewIsLandscape || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || [[UIScreen screens] count] != 1))
        [self scheduleImagesTimer];
    // Start metadata reading.
    DLog(@"Starting metadata handler...");
    [self metatadaHandler:nil];
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
    self.songInfoButton.enabled = NO;
    self.hdImage.hidden  = NO;
}

-(void)interfacePsd
{
    DLog(@"*** interfacePsd");
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = NO;
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-left"] forState:UIControlStateNormal];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-left"] forState:UIControlStateHighlighted];
    [self.playOrStopButton setImage:[UIImage imageNamed:@"pbutton-left"] forState:UIControlStateSelected];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd-active"] forState:UIControlStateNormal];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd-active"] forState:UIControlStateHighlighted];
    [self.psdButton setImage:[UIImage imageNamed:@"pbutton-psd-active"] forState:UIControlStateSelected];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateNormal];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateHighlighted];
    [self.songListButton setImage:[UIImage imageNamed:@"pbutton-addsong"] forState:UIControlStateSelected];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
    self.songInfoButton.enabled = YES;
    self.rpWebButton.enabled = YES;
    self.rpWebButton.hidden = NO;
    self.lyricsButton.enabled = YES;
    if(self.viewIsLandscape)
        self.minimizerButton.enabled = YES;
    self.songIsAlreadySaved = NO;
    self.hdImage.hidden = NO;
    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    [self.spinner stopAnimating];
    // Only if the app is active, if this is called via events there's no need to load images
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive  && (self.viewIsLandscape || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || [[UIScreen screens] count] != 1))
        [self scheduleImagesTimer];
    DLog(@"Getting PSD metadata...");
    [self metatadaHandler:nil];
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
    self.songInfoButton.enabled = NO;
    self.hdImage.hidden = NO;
}

- (void) interfaceToMinimized
{
    DLog(@"interfaceToMinimized");
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = self.supportRPButton.alpha = 0.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                             self.psdButton.alpha = self.songListButton.alpha = 0.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             self.lyricsText.frame = CGRectMake(22, 117, 352, 534);
                             self.hdImage.frame = CGRectMake(2, 97, 1020, 574);
                             self.dissolveHdImage.frame = CGRectMake(2, 97, 1020, 574);
                             self.minimizerButton.frame = CGRectMake(2, 97, 1020, 574);
                             self.metadataInfo.frame = CGRectMake(174, 707, 830, 21);
                             self.songNameButton.frame = CGRectMake(504, 707, 500, 21);
                             self.playOrStopButton.frame = CGRectMake(10, 701, 75, 30);
                             self.psdButton.frame = CGRectMake(95, 701, 75, 30);
                             self.songInfoButton.frame = CGRectMake(180, 701, 75, 30);
                             self.lyricsButton.frame = CGRectMake(265, 701, 75, 30);
                             self.songListButton.frame = CGRectMake(350, 701, 75, 30);
                             self.separatorImage.frame = CGRectMake(0, 672, 1024, 23);
                             self.logoImage.frame = CGRectMake(20, 2, 300, 94);
                         }
                         else
                         {
                             if([UIScreen mainScreen].bounds.size.height == 568.0f)
                             { // iPhone 5
                                 self.hdImage.frame = CGRectMake(0, 0, 568, 320);
                                 self.dissolveHdImage.frame = CGRectMake(0, 0, 568, 320);
                                 self.minimizerButton.frame = CGRectMake(0, 0, 568, 320);
                                 self.metadataInfo.frame = CGRectMake(109, 3, 450, 21);
                                 self.songNameButton.frame = CGRectMake(98, 2, 450, 21);
                                 self.playOrStopButton.frame = CGRectMake(504, 290, 60, 25);
                                 self.songInfoButton.frame = CGRectMake(5, 290, 60, 25);
                                 self.iPhoneLogoImage.frame = CGRectMake(4, 1, 25, 25);
                             }
                             else
                             { // "normal" iPhone
                                 self.songInfoButton.alpha = 1.0;
                                 self.hdImage.frame = CGRectMake(0, 25, 480, 270);
                                 self.dissolveHdImage.frame = CGRectMake(0, 25, 480, 270);
                                 self.minimizerButton.frame = CGRectMake(0, 25, 480, 270);
                                 self.metadataInfo.frame = CGRectMake(98, 2, 373, 21);
                                 self.songNameButton.frame = CGRectMake(98, 2, 373, 21);
                                 self.playOrStopButton.frame = CGRectMake(421, 298, 50, 20);
                                 self.songInfoButton.frame = CGRectMake(5, 298, 50, 20);
                                 self.iPhoneLogoImage.frame = CGRectMake(9, 0, 25, 25);
                             }
                             // All iPhones
                         }
                         self.aboutButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = YES;
                         self.interfaceState = kInterfaceMinimized;
                     }];
}

- (void) interfaceToNormal
{
    DLog(@"interfaceToNormal");
    self.minimizerButton.enabled = self.lyricsButton.enabled = YES;
    self.lyricsButton.hidden = self.separatorImage.hidden = self.logoImage.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = self.hdImage.hidden = self.lyricsButton.hidden = NO;
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.coverImageView.alpha = 0.0;
                         self.lyricsButton.alpha = self.logoImage.alpha = self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = self.lyricsButton.alpha = self.separatorImage.alpha = self.supportRPButton.alpha = 1.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             self.lyricsButton.alpha = self.songListButton.alpha = 1.0;
                             self.lyricsText.frame = CGRectMake(22, 22, 352, 534);
                             self.lyricsButton.frame = CGRectMake(598, 646, 75, 30);
                             if(self.isLyricsToBeShown)
                             {
                                 self.lyricsText.hidden = NO;
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateNormal];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateHighlighted];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateSelected];
                             }
                             else
                             {
                                 self.lyricsText.hidden = YES;
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateNormal];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateHighlighted];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateSelected];
                             }
                             self.hdImage.frame = CGRectMake(2, 2, 1020, 574);
                             self.dissolveHdImage.frame = CGRectMake(2, 2, 1020, 574);
                             self.minimizerButton.frame = CGRectMake(2, 2, 1020, 574);
                             self.metadataInfo.frame = CGRectMake(23, 605, 830, 21);
                             self.songNameButton.frame = CGRectMake(353, 605, 500, 21);
                             self.playOrStopButton.frame = CGRectMake(328, 646, 75, 30);
                             self.songInfoButton.frame = CGRectMake(508, 646, 75, 30);
                             self.songListButton.frame = CGRectMake(778, 646, 75, 30);
                             self.separatorImage.frame = CGRectMake(0, 577, 1024, 23);
                             self.psdButton.frame = CGRectMake(418, 646, 75, 30);
                             self.supportRPButton.frame = CGRectMake(688, 646, 75, 30);
                             self.logoImage.frame = CGRectMake(20, 626, 300, 94);
                             self.bitrateSelector.frame = CGRectMake(328, 699, 255, 30);
                             self.spinner.frame = CGRectMake(932, 655, 37, 37);
                             self.coverImageView.frame = CGRectMake(880, 604, 140, 140);
                             self.rpWebButton.frame = CGRectMake(880, 604, 140, 140);
                             self.volumeViewContainer.frame = CGRectMake(598, 699, 255, 29);
                             self.metadataInfo.font = [UIFont systemFontOfSize:18.0];
                             self.metadataInfo.shadowColor = [UIColor clearColor];
                             self.aboutButton.frame = CGRectMake(23, 607, 18, 19);
                         }
                         else
                         {
                             if([UIScreen mainScreen].bounds.size.height == 568.0f)
                             { // iPhone 5
                                 self.hdImage.frame = CGRectMake(0, 0, 568, 320);
                                 self.dissolveHdImage.frame = CGRectMake(0, 0, 568, 320);
                                 self.minimizerButton.frame = CGRectMake(0, 0, 568, 320);
                                 self.metadataInfo.frame = CGRectMake(98, 16, 450, 21);
                                 self.songNameButton.frame = CGRectMake(98, 16, 450, 21);
                                 self.songInfoButton.frame = CGRectMake(34, 281, 75, 30);
                                 self.bitrateSelector.frame = CGRectMake(117, 281, 110, 30);
                                 self.psdButton.frame = CGRectMake(235, 281, 75, 30);
                                 self.volumeViewContainer.frame = CGRectMake(318, 281, 158, 30);
                                 self.playOrStopButton.frame = CGRectMake(484, 281, 75, 30);
                             }
                             else
                             { // "normal" iPhone
                                 self.songInfoButton.alpha = 0.0;
                                 self.hdImage.frame = CGRectMake(0, 0, 480, 270);
                                 self.dissolveHdImage.frame = CGRectMake(0, 0, 480, 270);
                                 self.minimizerButton.frame = CGRectMake(0, 0, 480, 270);
                                 self.metadataInfo.frame = CGRectMake(98, 16, 373, 21);
                                 self.songNameButton.frame = CGRectMake(98, 16, 373, 21);
                                 self.songInfoButton.frame = CGRectMake(34, 278, 36, 36);
                                 self.playOrStopButton.frame = CGRectMake(396, 281, 75, 30);
                                 self.bitrateSelector.frame = CGRectMake(35, 281, 110, 30);
                                 self.psdButton.frame = CGRectMake(153, 281, 75, 30);
                                 self.songListButton.frame = CGRectMake(235, 278, 36, 36);
                                 self.volumeViewContainer.frame = CGRectMake(236, 281, 152, 30);
                             }
                             // in any iPhone...
                             self.supportRPButton.alpha = self.songListButton.alpha = 0.0;
                             self.aboutButton.frame = CGRectMake(9, 286, 18, 19);
                             self.iPhoneLogoImage.image = [UIImage imageNamed:@"SmallLogo_rphd"];
                             self.iPhoneLogoImage.frame = CGRectMake(9, 9, 40, 40);
                             self.hdImage.alpha = self.dissolveHdImage.alpha = 1.0;
                             self.psdButton.alpha = 1.0;
                             self.metadataInfo.shadowColor = [UIColor blackColor];
                             self.lyricsText.hidden = YES;
                             self.lyricsButton.hidden = YES;
                         }
                         // Both iPad and iPhone
                         self.aboutButton.alpha = 1.0;
                         self.metadataInfo.numberOfLines = 1;
                         self.metadataInfo.text = self.rawMetadataString;
                         self.metadataInfo.textColor = [UIColor whiteColor];
                         self.metadataInfo.textAlignment = NSTextAlignmentRight;
                         self.view.backgroundColor = [UIColor blackColor];
                         self.bitrateSelector.tintColor = [UIColor darkGrayColor];
                     }
                     completion:^(BOOL finished) {
                         self.interfaceState = kInterfaceNormal;
                         self.volumeViewContainer.backgroundColor = [UIColor clearColor];
                         for (UIView *view in [self.volumeViewContainer subviews])
                             [view removeFromSuperview];
                         if (!TARGET_IPHONE_SIMULATOR)
                         {
                             MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:self.volumeViewContainer.bounds];
                             DLog(@"size of VolumeView is %@, %@", NSStringFromCGPoint(myVolumeView.frame.origin), NSStringFromCGSize(myVolumeView.frame.size));
                             [self.volumeViewContainer addSubview:myVolumeView];
                             myVolumeView = nil;
                         }
                         else
                         {
                             UISlider *myVolumeView = [[UISlider alloc] initWithFrame:self.volumeViewContainer.bounds];
                             myVolumeView.value = 0.5;
                             [self.volumeViewContainer addSubview: myVolumeView];
                             myVolumeView = nil;
                         }
                     }];
}

- (void)interfaceToZoomed
{
    DLog(@"interfaceToZoomed");
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.logoImage.alpha = self.bitrateSelector.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.separatorImage.alpha = self.aboutButton.alpha = 0.0;
                         self.hdImage.frame = CGRectMake(0, 0, 1024, 768);
                         self.dissolveHdImage.frame = CGRectMake(0, 0, 1024, 768);
                         self.minimizerButton.frame = CGRectMake(0, 0, 1024, 768);
                         self.metadataInfo.frame = CGRectMake(174, 707, 830, 21);
                         self.songNameButton.frame = CGRectMake(504, 707, 500, 21);
                         self.playOrStopButton.frame = CGRectMake(10, 695, 43, 43);
                         self.psdButton.frame = CGRectMake(70, 695, 43, 43);
                         self.songInfoButton.frame = CGRectMake(130, 695, 43, 43);
                         self.songListButton.frame = CGRectMake(190, 695, 43, 43);
                         self.lyricsButton.frame = CGRectMake(250, 695, 43, 43);
                         self.separatorImage.frame = CGRectMake(0, 672, 1024, 23);
                     }
                     completion:^(BOOL finished) {
                         self.logoImage.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = YES;
                         self.logoImage.frame = CGRectMake(20, 626, 300, 94);
                         self.interfaceState = kInterfaceZoomed;
                         self.metadataInfo.shadowColor = [UIColor blackColor];
                     }];
}

-(void)interfaceToPortrait:(NSTimeInterval)animationDuration
{
    DLog(@"interfaceToPortrait");
    self.minimizerButton.enabled = NO;
    self.coverImageView.hidden = NO;
    self.lyricsButton.hidden = self.logoImage.hidden = self.bitrateSelector.hidden = self.rpWebButton.hidden = self.volumeViewContainer.hidden = self.separatorImage.hidden = NO;
    [UIView animateWithDuration:animationDuration
                     animations:^(void) {
                         self.lyricsButton.alpha = 0.0;
                         self.coverImageView.alpha = 1.0;
                         self.lyricsButton.alpha = self.logoImage.alpha = self.bitrateSelector.alpha = self.songListButton.alpha = self.rpWebButton.alpha = self.volumeViewContainer.alpha = self.supportRPButton.alpha = 1.0;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             self.separatorImage.alpha = 1.0;
                             self.separatorImage.hidden = NO;
                             self.separatorImage.frame = CGRectMake(0, 428, 768, 23);
                             self.hdImage.frame = CGRectMake(2, 2, 764, 425);
                             self.dissolveHdImage.frame = CGRectMake(2, 2, 764, 425);
                             self.minimizerButton.frame = CGRectMake(2, 2, 764, 430);
                             self.lyricsText.hidden = NO;
                             self.lyricsText.frame = CGRectMake(20, 777, 352, 227);
                             self.metadataInfo.frame = CGRectMake(20, 466, 728, 62);
                             self.songNameButton.frame = CGRectMake(20, 466, 728, 62);
                             self.playOrStopButton.frame = CGRectMake(418, 699, 75, 30);
                             self.supportRPButton.frame = CGRectMake(418, 954, 75, 30);
                             self.songListButton.frame = CGRectMake(546, 954, 75, 30);
                             self.psdButton.frame = CGRectMake(546, 699, 75, 30);
                             self.logoImage.frame = CGRectMake(433, 557, 300, 94);
                             self.bitrateSelector.frame = CGRectMake(418, 789, 330, 30);
                             self.spinner.frame = CGRectMake(178, 638, 37, 37);
                             self.coverImageView.frame = CGRectMake(96, 557, 200, 200);
                             self.rpWebButton.frame = CGRectMake(96, 557, 200, 200);
                             self.volumeViewContainer.frame = CGRectMake(418, 874, 330, 25);
                             self.lyricsButton.alpha = 0.0;
                             self.metadataInfo.font = [UIFont systemFontOfSize:22.0];
                             self.aboutButton.frame = CGRectMake(701, 959, 18, 19);
                             self.songInfoButton.frame = CGRectMake(673, 699, 75, 30);
                         }
                         else
                         {
                             if([UIScreen mainScreen].bounds.size.height == 568.0f)
                             { // iPhone 5
                                 self.coverImageView.frame = CGRectMake(20, 20, 280, 280);
                                 self.lyricsText.frame = CGRectMake(22, 22, 276, 276);
                                 self.hdImage.frame = CGRectMake(2, 2, 764, 425);
                                 self.dissolveHdImage.frame = CGRectMake(2, 2, 764, 425);
                                 self.metadataInfo.frame = CGRectMake(20, 310, 280, 40);
                                 self.songNameButton.frame = CGRectMake(20, 310, 280, 40);
                                 self.iPhoneLogoImage.frame = CGRectMake(20, 359, 280, 42);
                                 self.aboutButton.frame = CGRectMake(297, 371, 18, 19); //
                                 self.volumeViewContainer.frame = CGRectMake(20, 419, 197, 25); //
                                 self.songInfoButton.frame = CGRectMake(20, 470, 75, 30); //
                                 self.lyricsButton.frame = CGRectMake(20, 524, 75, 30); //
                                 self.bitrateSelector.frame = CGRectMake(103, 470, 114, 30); //
                                 self.supportRPButton.frame = CGRectMake(225, 524, 75, 30); //
                                 self.songListButton.frame = CGRectMake(123, 524, 75, 30);
                                 self.psdButton.frame = CGRectMake(225, 470, 75, 30);
                                 self.playOrStopButton.frame = CGRectMake(225, 417, 75, 30);
                             }
                             else
                             { // "normal" iPhone
                                 self.songInfoButton.alpha = 1.0;
                                 self.coverImageView.frame = CGRectMake(40, 20, 240, 240);
                                 self.songNameButton.frame = CGRectMake(40, 20, 240, 240);
                                 self.lyricsText.frame = CGRectMake(42, 22, 236, 236);
                                 self.hdImage.frame = CGRectMake(0, 0, 480, 270);
                                 self.dissolveHdImage.frame = CGRectMake(0, 0, 480, 270);
                                 self.iPhoneLogoImage.frame = CGRectMake(21, 263, 267, 40);
                                 self.metadataInfo.frame = CGRectMake(20, 303, 280, 40);
                                 self.songNameButton.frame = CGRectMake(20, 303, 280, 40);
                                 self.aboutButton.frame = CGRectMake(296, 276, 18, 19);
                                 self.volumeViewContainer.frame = CGRectMake(20, 350, 197, 30);
                                 self.playOrStopButton.frame = CGRectMake(225, 350, 75, 30);
                                 self.songInfoButton.frame = CGRectMake(20, 390, 75, 30); //
                                 self.bitrateSelector.frame = CGRectMake(103, 390, 114, 30);
                                 self.psdButton.frame = CGRectMake(225, 390, 75, 30);
                                 self.lyricsButton.frame = CGRectMake(20, 430, 75, 30);
                                 self.songListButton.frame = CGRectMake(123, 430, 75, 30);
                                 self.supportRPButton.frame = CGRectMake(225, 430, 75, 30);
                             }
                             // in any iPhone...
                             self.lyricsButton.alpha = 1.0;
                             self.iPhoneLogoImage.image = [UIImage imageNamed:@"logo_2011_horiz"];
                             if(self.isLyricsToBeShown)
                             {
                                 self.lyricsText.hidden = NO;
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateNormal];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateHighlighted];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics-active"] forState:UIControlStateSelected];
                             }
                             else
                             {
                                 self.lyricsText.hidden = YES;
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateNormal];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateHighlighted];
                                 [self.lyricsButton setImage:[UIImage imageNamed:@"pbutton-lyrics"] forState:UIControlStateSelected];
                             }
                             self.hdImage.alpha = self.dissolveHdImage.alpha = 0.0;
                             self.psdButton.alpha = self.songListButton.alpha = 1.0;
                         }
                         // Both iPad and iPhone
                         self.aboutButton.alpha = 1.0;
                         self.metadataInfo.numberOfLines = 2;
                         self.metadataInfo.text = self.rawMetadataString;
                         self.metadataInfo.textAlignment = NSTextAlignmentCenter;
                         self.metadataInfo.shadowColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
                         self.interfaceState = kInterfaceNormal;
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                         {
                             self.hdImage.hidden = YES;
                         }
                         self.volumeViewContainer.backgroundColor = [UIColor clearColor];
                         for (UIView *view in [self.volumeViewContainer subviews])
                             [view removeFromSuperview];
                         if (!TARGET_IPHONE_SIMULATOR)
                         {
                             MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:self.volumeViewContainer.bounds];
                             DLog(@"size of VolumeView is %@, %@", NSStringFromCGPoint(myVolumeView.frame.origin), NSStringFromCGSize(myVolumeView.frame.size));
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
                         if(self.theStreamMetadataTimer)
                             [self.theStreamMetadataTimer fire];
                         if(self.theImagesTimer)
                             [self.theImagesTimer fire];
                     }];
}

@end
