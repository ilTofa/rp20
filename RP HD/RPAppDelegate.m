//
//  RPAppDelegate.m
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPAppDelegate.h"

#import "RPViewController.h"

@implementation RPAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

@synthesize windowTV = _windowTV;
@synthesize TVviewController = _TVviewController;

- (void) myScreenInit:(UIScreen *)connectedScreen
{
    NSLog(@"Init TV screen");
    //Intitialise TV Screen
    if(!self.windowTV)
    {
        NSLog(@"window init");
        CGRect frame = connectedScreen.bounds;
        self.windowTV = [[UIWindow alloc] initWithFrame:frame];
        self.windowTV.backgroundColor = [UIColor blackColor];
        [self.windowTV setScreen:connectedScreen];
//        self.windowTV.hidden = NO;
    }
    // Generate a view controller and substitute the existing one.
    self.TVviewController = [[RPTVViewController alloc] initWithNibName:@"RPTVViewController" bundle:[NSBundle mainBundle]];
    UIViewController* release = self.windowTV.rootViewController;
    self.windowTV.rootViewController = self.TVviewController;
    [release removeFromParentViewController];
}

- (void)screenDidConnect:(NSNotification *)notification 
{
    NSLog(@"Second screen notification fired (and catched)");
    [self myScreenInit:[notification object]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[RPViewController alloc] initWithNibName:@"RPViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
