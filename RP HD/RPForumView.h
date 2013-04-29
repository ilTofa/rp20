//
//  RPForumView.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

// #define kRPCurrentSongForum @"http://www.radioparadise.com/m-content.php?name=Music&file=songinfo&song_id=%@"
#define kRPCurrentSongForum @"http://www.radioparadise.com/ios-content.php?name=Music&file=songinfo&song_id=%@"

@interface RPForumView : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *theWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goForwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *theSpinner;

@property (copy, nonatomic) NSString *songId;
@property (copy, nonatomic) NSString *currentSongName;
@property BOOL isForumShown;

- (IBAction)viewIsDone:(id)sender;
- (IBAction)goBackClicked:(id)sender;
- (IBAction)goForwardClicked:(id)sender;
- (IBAction)refreshClicked:(id)sender;
- (IBAction)actionClicked:(id)sender;

@end
