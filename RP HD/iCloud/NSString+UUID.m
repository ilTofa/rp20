//
//  NSString+UUID.m
//  radioz
//
//  Created by Giacomo Tufano on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"
// for SHA-256
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (UUID)

+ (NSString *)uuid
{
    NSString *uuidString = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) 
    {
        uuidString = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    return uuidString;
}

- (NSString *)sha256
{
    // build the password using SHA-256
	unsigned char hashedChars[32];
	CC_SHA256([self UTF8String],
			  [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
			  hashedChars);
	NSString *hashedData = [[NSData dataWithBytes:hashedChars length:32] description];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@" " withString:@""];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hashedData;
}

@end
