//
//  SongAdder.h
//  RP HD
//
//  Created by Giacomo Tufano on 04/09/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Song.h"

@interface SongAdder : NSObject

+(BOOL)addSong:(Song *)theSong error:(NSError **)outError;

@end
