//
//  SongAdder.h
//  RP HD
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Song.h"

@interface SongAdder : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSDate * dateadded;
@property (nonatomic, retain) NSString * sha;
@property (nonatomic, retain) NSData *cover;

-(id)initWithTitle:(NSString *)title andArtist:(NSString *)artist andCoversheet:(UIImage *)cover;
-(BOOL)addSong:(NSError **)outError;

@end
