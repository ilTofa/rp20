//
//  RPAppDelegate.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "RPTVViewController.h"
#import "PiwikTracker.h"

#define kTVInited @"tvWindowsInited"

@class RPViewController;
@class CoreDataController;

@interface RPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *windowTV;

@property (nonatomic, strong, readonly) CoreDataController *coreDataController;

@property (strong, nonatomic) RPViewController *viewController;
@property (strong, nonatomic) RPTVViewController *TVviewController;

@property (nonatomic, strong) PiwikTracker *tracker;

@end
