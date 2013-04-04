//
//  RPAppDelegate.m
//  Radio Paradise
//
//  Created by Giacomo Tufano on 04/04/13.
//  Copyright (c) 2013 Giacomo Tufano. All rights reserved.
//

#import "RPAppDelegate.h"

#import "CoreDataController.h"

@implementation RPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Init core data
    _coreDataController = [[CoreDataController alloc] init];
    //    [_coreDataController nukeAndPave];
    [_coreDataController loadPersistentStores];
}

@end
