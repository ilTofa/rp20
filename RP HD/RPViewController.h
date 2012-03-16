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

#define kRPURL24K @"http://stream-tx1.radioparadise.com:8022"
#define kRPURL64K @"http://207.200.96.231:8004"
#define kRPURL128K @"http://scfire-mtc-aa03.stream.aol.com:80/stream/1048"

#define kRPm3u24K @"http://www.radioparadise.com/musiclinks/rp_24aac.m3u"
#define kRPm3u64K @"http://www.radioparadise.com/musiclinks/rp_64aac.m3u"
#define kRPm3u128K @"http://www.radioparadise.com/musiclinks/rp_128.m3u"

#define kHDImageURLURL @"http://radioparadise.com/readtxt.php"

@interface RPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *metadataInfo;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *playOrStopButton;
@property (weak, nonatomic) IBOutlet UIView *volumeViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *hdImage;

@property (strong, nonatomic) AudioStreamer *theStreamer;
@property (strong, nonatomic) NSOperationQueue *imageLoadQueue;
@property (strong, nonatomic) NSTimer *theTimer;

@property (copy, nonatomic) NSString *theURL;

- (IBAction)playOrStop:(id)sender;
- (IBAction)bitrateChanged:(id)sender;

@end
