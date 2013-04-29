//
//  NSString+UUID.m
//  radioz
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
			  (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
			  hashedChars);
	NSString *hashedData = [[NSData dataWithBytes:hashedChars length:32] description];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@" " withString:@""];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hashedData = [hashedData stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hashedData;
}

@end
