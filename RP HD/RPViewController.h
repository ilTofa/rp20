//
//  RPViewController.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *metadataInfo;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *playOrStopButton;
@property (weak, nonatomic) IBOutlet UIView *volumeViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)playOrStop:(id)sender;
- (IBAction)bitrateChanged:(id)sender;
- (IBAction)refreshImage:(id)sender;

@end
