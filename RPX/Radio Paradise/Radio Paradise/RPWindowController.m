//
//  RPWindowController.m
//  Radio Paradise
//
//  Created by Giacomo Tufano on 04/04/13.
//  Copyright (c) 2013 Giacomo Tufano. All rights reserved.
//

#import "RPWindowController.h"

#import <AVFoundation/AVFoundation.h>

@interface RPWindowController ()

@property (copy, nonatomic) NSString *cookieString;
@property (nonatomic) BOOL isPSDPlaying;
@property (strong, nonatomic) AVPlayer *theStreamer;
@property (strong, nonatomic) NSOperationQueue *imageLoadQueue;
@property (copy, nonatomic) NSString *rawMetadataString;
@property (copy, nonatomic) NSString *theRedirector;
@property BOOL songIsAlreadySaved;
@property (strong) NSTimer *theStreamMetadataTimer;


@property (weak, nonatomic) IBOutlet NSTextField *metadataInfo;
@property (weak) IBOutlet NSButton *psdButton;
@property (weak) IBOutlet NSButton *playOrStopButton;
@property (weak) IBOutlet NSButton *songListButton;
@property (weak) IBOutlet NSPopUpButton *bitrateSelector;
@property (weak) IBOutlet NSButton *lyricsButton;
@property (weak) IBOutlet NSButton *supportRPButton;
@property (weak) IBOutlet NSImageView *coverImageView;
@property (weak) IBOutlet NSButton *songInfoButton;
@property BOOL isLyricsToBeShown;

@end

@implementation RPWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib {
    DLog(@"Initing UI");
    // reset text
    self.metadataInfo.stringValue = self.rawMetadataString = @"";
    // Let's see if we already have a preferred bitrate
    long savedBitrate = [[NSUserDefaults standardUserDefaults] integerForKey:@"bitrate"];
//    if(savedBitrate == 0) {
        self.theRedirector = kRPURL64K;
//    } else {
//        self.bitrateSelector.selectedSegmentIndex = savedBitrate - 1;
//        [self bitrateChanged:self.bitrateSelector];
//    }
//
    self.imageLoadQueue = [[NSOperationQueue alloc] init];
    // Set PSD to not logged, not playing
    self.cookieString = nil;
    self.isPSDPlaying = NO;
    [self playMainStream];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - HD images loading

-(void)scheduleImagesTimer {

}

#pragma mark -
#pragma mark Metadata management

-(void)metatadaHandler:(NSTimer *)timer {
    
}

#pragma mark - UI management

-(void)interfaceStop
{
    DLog(@"*** interfaceStop");
    self.metadataInfo.stringValue = self.rawMetadataString = @"";
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[NSImage imageNamed:@"pbutton-play"]];
    [self.psdButton setImage:[NSImage imageNamed:@"pbutton-psd"]];
    [self.songListButton setImage:[NSImage imageNamed:@"pbutton-songlist"]];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
//    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = YES;
//    self.hdImage.hidden = self.dissolveHdImage.hidden = YES;
    self.songInfoButton.enabled = NO;
    self.lyricsButton.enabled = NO;
    self.songIsAlreadySaved = YES;
//    if(self.isLyricsToBeShown)
//        [self showLyrics:nil];
    self.coverImageView.image = nil;
    if(self.theStreamMetadataTimer != nil)
    {
        [self.theStreamMetadataTimer invalidate];
        self.theStreamMetadataTimer = nil;
    }
}

-(void)interfaceStopPending
{
    DLog(@"*** interfaceStopPending");
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.songInfoButton.enabled = NO;
    self.lyricsButton.enabled = NO;
//    if(self.isLyricsToBeShown)
//        [self showLyrics:nil];
}

-(void)interfacePlay
{
    DLog(@"*** interfacePlay");
    self.bitrateSelector.enabled = YES;
    [self.playOrStopButton setImage:[NSImage imageNamed:@"pbutton-stop"]];
    [self.psdButton setImage:[NSImage imageNamed:@"pbutton-psd"]];
    [self.songListButton setImage:[NSImage imageNamed:@"pbutton-addsong"]];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
//    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    self.songInfoButton.enabled = YES;
//    self.hdImage.hidden = NO;
    self.lyricsButton.enabled = YES;
    self.songIsAlreadySaved = NO;
    [self scheduleImagesTimer];
    // Start metadata reading.
    DLog(@"Starting metadata handler...");
    [self metatadaHandler:nil];
}

-(void)interfacePlayPending
{
    DLog(@"*** interfacePlayPending");
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.songInfoButton.enabled = NO;
//    self.hdImage.hidden  = NO;
}

-(void)interfacePsd
{
    DLog(@"*** interfacePsd");
    self.psdButton.enabled = YES;
    self.bitrateSelector.enabled = NO;
    [self.playOrStopButton setImage:[NSImage imageNamed:@"pbutton-left"]];
    [self.psdButton setImage:[NSImage imageNamed:@"pbutton-psd-active"]];
    [self.songListButton setImage:[NSImage imageNamed:@"pbutton-addsong"]];
    self.playOrStopButton.enabled = YES;
    self.psdButton.enabled = YES;
    self.songInfoButton.enabled = YES;
    self.lyricsButton.enabled = YES;
    self.songIsAlreadySaved = NO;
//    self.hdImage.hidden = NO;
//    ((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).windowTV.hidden = NO;
    [self scheduleImagesTimer];
    DLog(@"Getting PSD metadata...");
    [self metatadaHandler:nil];
}

-(void)interfacePsdPending
{
    DLog(@"*** interfacePsdPending");
    self.playOrStopButton.enabled = NO;
    self.bitrateSelector.enabled = NO;
    self.psdButton.enabled = NO;
    self.songInfoButton.enabled = NO;
//    self.hdImage.hidden = NO;
}

#pragma mark - Notifications

-(void)activateNotifications
{
    DLog(@"*** activateNotifications");
    [self.theStreamer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(void)removeNotifications
{
    DLog(@"*** removeNotifications");
    [self.theStreamer removeObserver:self forKeyPath:@"status"];
}


#pragma mark - Actions

- (void)playMainStream
{
    [self interfacePlayPending];
    self.theStreamer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.theRedirector]];
    [self activateNotifications];
    [self.theStreamer play];
}


@end
