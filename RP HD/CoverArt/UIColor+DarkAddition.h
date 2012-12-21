//
//  UIColor+DarkAddition.h
//  CoverArt
//
//  Created by Giacomo Tufano on 18/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//  Derived (with modifications) from BSD licensed code
//  Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DarkAddition)

- (BOOL)pc_isDarkColor;
- (BOOL)pc_isDistinct:(UIColor *)compareColor;
- (UIColor *)pc_colorWithMinimumSaturation:(CGFloat)saturation;
- (BOOL)pc_isBlackOrWhite;
- (BOOL)pc_isContrastingColor:(UIColor *)color;

@end
