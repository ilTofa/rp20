//
//  RPAppDelegate.m
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPAppDelegate.h"

#import "RPViewController.h"
#import "LocalyticsSession.h"
#import "Appirater.h"
#import "CoreDataController.h"

@implementation RPAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

@synthesize windowTV = _windowTV;
@synthesize TVviewController = _TVviewController;

- (void) myScreenInit:(UIScreen *)connectedScreen
{
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"TV Screen inited"];
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
    // Init core data
    _coreDataController = [[CoreDataController alloc] init];
    [_coreDataController loadPersistentStores];

    // Init Localytics & appirater
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"e11cda37f7203321df08793-aeb86da4-fda0-11e1-53d7-00ef75f32667"];
    [Appirater setAppId:@"517818306"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
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
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

@end
