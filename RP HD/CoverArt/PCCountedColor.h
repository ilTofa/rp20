//
//  PCCountedColor.h
//  CoverArt
//
//  Created by Giacomo Tufano on 18/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//  Derived (with modifications) from BSD licensed code
//  Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCountedColor : NSObject

@property NSUInteger count;
@property (strong) UIColor *color;

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count;

@end
