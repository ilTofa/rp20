//
//  CoverArt.h
//  CoverArt
//
//  Created by Giacomo Tufano on 18/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//  Derived (with modifications) from BSD licensed code
//  Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoverArt : NSObject

+ (UIImage *)radialGradientImageOfSize:(CGSize)size withStartColor:(UIColor *)startColor endColor:(UIColor *)endColor centre:(CGPoint)centre radius:(float)radius;
+ (void)findBackgroundColor:(NSCountedSet*)colors backgroundColor:(UIColor **)backgroundColor textColor:(UIColor *)textColor;
+ (UIColor *)findTextColor:(UIImage *)image imageColors:(NSCountedSet**)colors lazy:(BOOL)lazy;

@end
