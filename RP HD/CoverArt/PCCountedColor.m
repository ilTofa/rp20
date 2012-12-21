//
//  PCCountedColor.m
//  CoverArt
//
//  Created by Giacomo Tufano on 18/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//  Derived (with modifications) from BSD licensed code
//  Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//

#import "PCCountedColor.h"

@implementation PCCountedColor

- (id)initWithColor:(UIColor *)color count:(NSUInteger)count
{
	self = [super init];
	
	if ( self )
	{
		self.color = color;
		self.count = count;
	}
	
	return self;
}

- (void)dealloc
{
	self.color = nil;
}


- (NSComparisonResult)compare:(PCCountedColor*)object
{
	if ( [object isKindOfClass:[PCCountedColor class]] )
	{
		if ( self.count < object.count )
		{
			return NSOrderedDescending;
		}
		else if ( self.count == object.count )
		{
			return NSOrderedSame;
		}
	}
    
	return NSOrderedAscending;
}


@end
