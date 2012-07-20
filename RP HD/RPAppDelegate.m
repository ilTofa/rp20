//
//  RPAppDelegate.m
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPAppDelegate.h"

#import "RPViewController.h"
#import "FlurryAnalytics.h"
#import "Appirater.h"

@implementation RPAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

@synthesize windowTV = _windowTV;
@synthesize TVviewController = _TVviewController;

- (void) myScreenInit:(UIScreen *)connectedScreen
{
    [FlurryAnalytics logEvent:@"TV Screen inited"];
    DLog(@"Init TV screen");
    //Intitialise TV Screen
    if(!self.windowTV)
    {
        DLog(@"window init");
        CGRect frame = connectedScreen.bounds;
        self.windowTV = [[UIWindow alloc] initWithFrame:frame];
        self.windowTV.backgroundColor = [UIColor blackColor];
        [self.windowTV setScreen:connectedScreen];
        self.windowTV.hidden = NO;
    }
    // Generate a view controller and substitute the existing one.
    self.TVviewController = [[RPTVViewController alloc] initWithNibName:@"RPTVViewController" bundle:[NSBundle mainBundle]];
    UIViewController* release = self.windowTV.rootViewController;
    self.windowTV.rootViewController = self.TVviewController;
    [release removeFromParentViewController];
    // Post a notification to init tvView data
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kTVInited object:nil]];
}

- (void)screenDidConnect:(NSNotification *)notification 
{
    DLog(@"Second screen notification fired (and catched)");
    [self myScreenInit:[notification object]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[RPViewController alloc] initWithNibName:@"RPViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    // Init Flurry Analytics & appirater
    [FlurryAnalytics startSession:@"PP44G74JCE81THYJRKTV"];
    [Appirater appLaunched:YES];
    // Now go for the second screen thing.
    if ([[UIScreen screens] count] > 1)
        [self myScreenInit:[[UIScreen screens] objectAtIndex:1]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
