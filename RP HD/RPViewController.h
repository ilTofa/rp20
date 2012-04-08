//
//  RPViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <QuartzCore/QuartzCore.h>
#import "AudioStreamer.h"
#import "RPAboutBox.h"
#import "RPForumView.h"

// #define kRPURL24K @"http://stream-tx1.radioparadise.com:8022"
// #define kRPURL64K @"http://207.200.96.231:8004"
// #define kRPURL128K @"http://scfire-mtc-aa03.stream.aol.com:80/stream/1048"

#define kRPURL24K @"http://www.radioparadise.com/musiclinks/rp_24aac.m3u"
#define kRPURL64K @"http://www.radioparadise.com/musiclinks/rp_64aac.m3u"
#define kRPURL128K @"http://www.radioparadise.com/musiclinks/rp_128.m3u"

#define kHDImageURLURL @"http://radioparadise.com/readtxt.php"

@interface RPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *metadataInfo;
// @property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *playOrStopButton;
@property (weak, nonatomic) IBOutlet UIView *volumeViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *hdImage;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *rpWebButton;
@property (weak, nonatomic) IBOutlet UIButton *minimizerButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bitrateSelector;
@property (weak, nonatomic) IBOutlet UIButton *songNameButton;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImage;

@property (strong, nonatomic) AudioStreamer *theStreamer;
@property (strong, nonatomic) NSOperationQueue *imageLoadQueue;
@property (strong, nonatomic) NSTimer *theTimer;
@property (strong, nonatomic) UIPopoverController *theAboutBox;
@property (strong, nonatomic) RPForumView *theWebView;
@property (nonatomic) BOOL isViewMinimized;

@property (copy, nonatomic) NSString *theURL;
@property (copy, nonatomic) NSString *theRedirector;
@property (copy, nonatomic) NSString *currentSongForumURL;

- (IBAction)playOrStop:(id)sender;
- (IBAction)bitrateChanged:(id)sender;
- (IBAction)presentAboutBox:(id)sender;
- (IBAction)presentRPWeb:(id)sender;
- (IBAction)songNameOverlayButton:(id)sender;
- (IBAction)minimizer:(id)sender;

@end
