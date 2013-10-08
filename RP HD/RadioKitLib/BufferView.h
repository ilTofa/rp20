//
//  BufferView.h
//  RadioEngine
//
//  Created by Brian Stormont on 6/3/09.
//  Copyright 2009 Stormy Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BufferView : UIView {

	NSUInteger bufferSize;
	NSUInteger bufferCount;
	NSUInteger currBuffPtr;
	NSUInteger bufferByteOffset;  // Used when listening to a file and we've skipped ahead so we don't have the earlier part of the file in memory
	
	UIColor	*bufferColor;
	UIColor *bufferNeedleColor;
}
@property (nonatomic) NSUInteger bufferSize, bufferCount, currBuffPtr, bufferByteOffset;
@property (nonatomic, retain) UIColor	*bufferColor;
@property (nonatomic, retain) UIColor	*bufferNeedleColor;

@end
