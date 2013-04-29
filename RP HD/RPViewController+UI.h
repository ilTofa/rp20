//
//  RPViewController+UI.h
//  RadioParadise
//
//  Created by Giacomo Tufano on 15/03/12.
//  ©2013 Giacomo Tufano.
//  Licensed under MIT license. See LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
