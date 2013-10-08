//
//  RPViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#include <QuartzCore/QuartzCore.h>
#include <AVFoundation/AVFoundation.h>
#import "RadioKit.h"
#import "RPAboutBox.h"
#import "RPForumView.h"
#import "RPLoginController.h"
#import "SongsViewController.h"

// #define kRPURL24K @"http://stream-tx1.radioparadise.com:8022"
// #define kRPURL64K @"http://207.200.96.231:8004"
// #define kRPURL128K @"http://scfire-mtc-aa03.stream.aol.com:80/stream/1048"

#define kRPURL24K @"http://www.radioparadise.com/musiclinks/rp_24aac.m3u"
#define kRPURL64K @"http://www.radioparadise.com/musiclinks/rp_64aac.m3u"
#define kRPURL128K @"http://www.radioparadise.com/musiclinks/rp_128aac.m3u"

#define kHDImageURLURL @"http://radioparadise.com/readtxt.php"
#define kHDImagePSDURL @"http://www.radioparadise.com/ajax_image_ipad.php"

#define kPsdFadeOutTime 4.0
#define kFadeInTime 2.5

typedef enum {
    kInterfaceNormal,
    kInterfaceMinimized,
    kInterfaceZoomed
} InterfaceMode;

@interface RPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *metadataInfo;
// @property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *playOrStopButton;
@property (weak, nonatomic) IBOutlet UIView *volumeViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak) IBOutlet UIImageView *hdImage;
@property (weak) IBOutlet UIImageView *dissolveHdImage;
@property (weak, nonatomic) IBOutlet UIButton *lyricsButton;
@property (weak, nonatomic) IBOutlet UIButton *rpWebButton;
@property (weak, nonatomic) IBOutlet UIButton *minimizerButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bitrateSelector;
@property (weak, nonatomic) IBOutlet UIButton *songNameButton;
@property (weak) IBOutlet UIImageView *separatorImage;
@property (weak) IBOutlet UIImageView *iPhoneLogoImage;
@property (weak, nonatomic) IBOutlet UIButton *psdButton;
@property (weak, nonatomic) IBOutlet UIButton *songInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *songListButton;
@property (weak) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITextView *lyricsText;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *supportRPButton;

@property (strong, nonatomic) RadioKit *theStreamer;
@property (strong, nonatomic) NSOperationQueue *imageLoadQueue;
@property (strong) NSTimer *theImagesTimer;
@property (strong) NSTimer *theStreamMetadataTimer;
@property (strong) NSTimer *thePsdTimer;
@property (strong, nonatomic) AVPlayer *thePsdStreamer;
@property (strong, nonatomic) AVPlayer *theOldPsdStreamer;
@property (strong, nonatomic) RPForumView *theWebView;
@property (strong, nonatomic) UIPopoverController *theLoginBox;

@property (strong) UIImage *coverImage;
@property (nonatomic) InterfaceMode interfaceState;
@property (nonatomic) BOOL isPSDPlaying;
@property (copy, nonatomic) NSString *currentSongId;
@property (nonatomic) NSNumber *psdDurationInSeconds;
@property BOOL isLyricsToBeShown;
@property BOOL songIsAlreadySaved;

@property BOOL viewIsLandscape;
@property BOOL viewIsRotating;

@property (copy, nonatomic) NSString *theURL;
@property (copy, nonatomic) NSString *theRedirector;
@property (copy, nonatomic) NSString *currentSongForumURL;
@property (copy, nonatomic) NSString *rawMetadataString;
@property (copy, nonatomic) NSString *cookieString;
@property BOOL interfaceIsTinted;

// Called from UI category
-(void)scheduleImagesTimer;
-(void)metatadaHandler:(NSTimer *)timer;

- (IBAction)playOrStop:(id)sender;
- (IBAction)bitrateChanged:(id)sender;
- (IBAction)presentAboutBox:(id)sender;
- (IBAction)presentRPWeb:(id)sender;
- (IBAction)minimizer:(id)sender;
- (IBAction)startPSD:(id)sender;
- (IBAction)songListAction:(id)sender;
- (IBAction)showLyrics:(id)sender;
- (IBAction)supportRP:(id)sender;

- (IBAction)showStatusBar:(id)sender;
- (IBAction)hideStatusBar:(id)sender;

@end
