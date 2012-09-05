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
#import "NSString+UUID.h"
#import "UIImage+RoundedCorner.h"

@implementation SongAdder

-(id)initWithTitle:(NSString *)title andArtist:(NSString *)artist andCoversheet:(UIImage *)cover
{
    self = [super init];
    if (self)
    {
        _title = title;
        _artist = artist;
        _dateadded = [[NSDate alloc] init];
        NSString *temp = [NSString stringWithFormat:@"%@ - %@", title, artist];
        _sha = [[NSString alloc] initWithString:[temp sha256]];
        if(cover == nil)
            cover = [UIImage imageNamed:@"RP-meta"];
        _cover = UIImagePNGRepresentation([cover roundedThumbnail:178 withFixedScale:YES cornerSize:6 borderSize:1]);
    }
    return self;
}

-(BOOL)addSong:(NSError **)outError
{
    BOOL retValue = YES;
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [addingContext setPersistentStoreCoordinator:((RPAppDelegate *)[[UIApplication sharedApplication] delegate]).coreDataController.psc];
    Song *theSongToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:addingContext];
    theSongToBeSaved.title = self.title;
    theSongToBeSaved.artist = self.artist;
    theSongToBeSaved.dateadded = self.dateadded;
    theSongToBeSaved.sha = self.sha;
    theSongToBeSaved.cover = self.cover;
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
