//
//  CoverArt.m
//  CoverArt
//
//  Created by Giacomo Tufano on 18/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//  Derived (with modifications) from BSD licensed code
//  Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//

#import "CoverArt.h"

#import "PCCountedColor.h"
#import "UIColor+DarkAddition.h"

@implementation CoverArt

+ (UIImage *)radialGradientImageOfSize:(CGSize)size withStartColor:(UIColor *)startColor endColor:(UIColor *)endColor centre:(CGPoint)centre radius:(float)radius
{
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    // Initialise
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    // Create the gradient's colours
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    CGFloat components[8];
    [startColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    [endColor getRed:&components[4] green:&components[5] blue:&components[6] alpha:&components[7]];
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // Normalise the 0-1 ranged inputs to the width of the image
    CGPoint myCentrePoint = CGPointMake(centre.x * size.width, centre.y * size.height);
    float myRadius = MIN(size.width, size.height) * radius;
    
    // Draw it!
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                 0, myCentrePoint, myRadius,
                                 kCGGradientDrawsAfterEndLocation);
    
    // Grab it as an autoreleased image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clean up
    CGColorSpaceRelease(myColorspace); // Necessary?
    CGGradientRelease(myGradient); // Necessary?
    UIGraphicsEndImageContext(); // Clean up
    return image;
}

+ (UIColor *)findTextColor:(UIImage *)image imageColors:(NSCountedSet**)colors lazy:(BOOL)lazy
{
//    [CoverArt imageDump:image];    
    CGImageRef cgimage = image.CGImage;
	
	NSInteger pixelsWide = CGImageGetWidth(cgimage);
	NSInteger pixelsHigh = CGImageGetHeight(cgimage);
    
    if(pixelsHigh != pixelsWide)
        DLog(@"*** WARNING *** image is not squared");
    
	NSCountedSet *imageColors = [[NSCountedSet alloc] initWithCapacity:pixelsWide * pixelsHigh];
	NSCountedSet *edgeColors = [[NSCountedSet alloc] initWithCapacity:(pixelsHigh + pixelsWide) * 2];
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;

    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = CFBridgingRelease(CGDataProviderCopyData(provider));
    const uint8_t* bytes = [data bytes];
    int step = (lazy) ? 3 : 1;
	for (NSUInteger x = 0; x < pixelsHigh; x += step)
	{
		for (NSUInteger y = 0; y < pixelsWide; y += step)
		{
            const uint8_t* pixel = &bytes[x * bpr + y * bytes_per_pixel];
            
			UIColor *color = [UIColor colorWithRed:pixel[0]/256.0 green:pixel[1]/256.0 blue:pixel[2]/256.0 alpha:pixel[3]/256.0];
            // Not really the edge, but 2 pixels inside...
			if (y == step + 1 || x == step + 1 || x > (pixelsWide - step) || y > (pixelsHigh - step))
				[edgeColors addObject:color];
			[imageColors addObject:color];
		}
	}
    
	*colors = imageColors;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[edgeColors count]];
    for (UIColor *curColor in edgeColors)
    {
		NSUInteger colorCount = [edgeColors countForObject:curColor];
		PCCountedColor *container = [[PCCountedColor alloc] initWithColor:curColor count:colorCount];
		[sortedColors addObject:container];
    }
    
	[sortedColors sortUsingSelector:@selector(compare:)];
	
	PCCountedColor *proposedTextColor = nil;
	if ([sortedColors count] > 0)
	{
		proposedTextColor = [sortedColors objectAtIndex:0];
		if ([proposedTextColor.color pc_isBlackOrWhite]) // want to choose color over black/white so we keep looking
		{
            for (PCCountedColor *nextProposedColor in sortedColors)
            {
				if (((double)nextProposedColor.count / (double)proposedTextColor.count) > .3 ) // make sure the second choice color is 30% as common as the first choice
				{
					if ( ![nextProposedColor.color pc_isBlackOrWhite] )
					{
						proposedTextColor = nextProposedColor;
						break;
					}
				}
				else
				{
					// reached color threshold less than 30% of the original proposed edge color so bail
					break;
				}
            }
			for ( NSInteger i = 1; i < [sortedColors count]; i++ )
			{
				PCCountedColor *nextProposedColor = [sortedColors objectAtIndex:i];
				if (((double)nextProposedColor.count / (double)proposedTextColor.count) > .3 ) // make sure the second choice color is 30% as common as the first choice
				{
					if ( ![nextProposedColor.color pc_isBlackOrWhite] )
					{
						proposedTextColor = nextProposedColor;
						break;
					}
				}
				else
				{
					// reached color threshold less than 30% of the original proposed edge color so bail
					break;
				}
			}
		}
	}
    else
        NSLog(@"[sortedColors count] == 0!");
	return proposedTextColor.color;
}

+ (void)findBackgroundColor:(NSCountedSet*)colors backgroundColor:(UIColor **)backgroundColor textColor:(UIColor *)textColor
{
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[colors count]];
	BOOL findDarkTextColor = ![textColor pc_isDarkColor];
	
    for (UIColor __strong *curColor in colors)
    {
		curColor = [curColor pc_colorWithMinimumSaturation:.15]; // make sure color isn't too pale or washed out
		if ( [curColor pc_isDarkColor] == findDarkTextColor )
		{
			NSUInteger colorCount = [colors countForObject:curColor];
			PCCountedColor *container = [[PCCountedColor alloc] initWithColor:curColor count:colorCount];
			[sortedColors addObject:container];
		}
    }
	
	[sortedColors sortUsingSelector:@selector(compare:)];
	UIColor *curColor;
	for (PCCountedColor *curContainer in sortedColors)
	{
		curColor = curContainer.color;
        
		if ( *backgroundColor == nil )
		{
			if ( [curColor pc_isContrastingColor:textColor] )
				*backgroundColor = curColor;
		}
	}
}

+(void)imageDump:(UIImage *)image
{
    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t __unused bytes_per_pixel = bpp / bpc;
    
    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
    
    NSLog(
          @"==== Image Dump ====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = %s\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask)     ? "YES" : "NO",
          (info & kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
}

@end
