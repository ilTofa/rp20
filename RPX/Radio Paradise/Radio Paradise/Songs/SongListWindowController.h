//
//  SongListWindowController.h
//  radioz
//
//  Created by Giacomo Tufano on 05/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SongListWindowController : NSWindowController

@property (weak, atomic) IBOutlet NSManagedObjectContext *sharedManagedObjectContext;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSTableView *theTable;

@property (strong, nonatomic) NSString *theSelectedTitle;
@property (strong, nonatomic) NSString *theSelectedArtist;
@property (strong, nonatomic) NSData *theSelectedCover;
@property (strong, nonatomic) NSURL *iTunesURL;

- (IBAction)gotoStore:(id)sender;
- (IBAction)deleteSong:(id)sender;

@end
