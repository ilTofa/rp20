//
//  RPAppDelegate.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPTVViewController.h"

#define kTVInited @"tvWindowsInited"

@class RPViewController;
@class CoreDataController;

@interface RPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *windowTV;

@property (nonatomic, strong, readonly) CoreDataController *coreDataController;

@property (strong, nonatomic) RPViewController *viewController;
@property (strong, nonatomic) RPTVViewController *TVviewController;

@end
