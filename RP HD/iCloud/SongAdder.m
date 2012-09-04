//
//  SongAdder.m
//  RP HD
//
//  Created by Giacomo Tufano on 04/09/12.
//
//

#import "SongAdder.h"

#import "CoreDataController.h"
#import "RPAppDelegate.h"

@implementation SongAdder

+(BOOL)addSong:(Song *)theSong error:(NSError **)outError
{
    BOOL retValue = YES;
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [addingContext setPersistentStoreCoordinator:((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).coreDataController.psc];
    Song *theSongToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:addingContext];
    theSongToBeSaved = [theSong copy];
    if (![addingContext save:outError])
    {
        // Log and return the error to the caller.
        NSLog(@"Unresolved error %@, %@", *outError, [*outError userInfo]);
        retValue = NO;
    }
    // release the adding managed object context
    addingContext = nil;
    return retValue;
}

@end
