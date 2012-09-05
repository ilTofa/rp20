//
//  Song.h
//  RP HD
//
//  Created by Giacomo Tufano on 05/09/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSDate * dateadded;
@property (nonatomic, retain) NSString * sha;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * cover;

@end
