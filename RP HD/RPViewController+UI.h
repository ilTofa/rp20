//
//  RPViewController+UI.h
//  RadioParadise
//
//  Created by Giacomo Tufano on 14/01/13.
//
//

#import "RPViewController.h"

@interface RPViewController (UI)

-(void)interfaceStop;
-(void)interfaceStopPending;
-(void)interfacePlay;
-(void)interfacePlayPending;
-(void)interfacePsd;
-(void)interfacePsdPending;
-(void)interfaceToMinimized;
-(void)interfaceToNormal;
-(void)interfaceToZoomed;
-(void)interfaceToPortrait:(NSTimeInterval)animationDuration;

@end
