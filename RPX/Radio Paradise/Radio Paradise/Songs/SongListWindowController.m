//
//  SongListWindowController.m
//  radioz
//
//  Created by Giacomo Tufano on 05/12/12.
//  Copyright (c) 2012 Giacomo Tufano. All rights reserved.
//

#import "SongListWindowController.h"

#import "RPAppDelegate.h"
#import "CoreDataController.h"
#import "Song.h"

@interface SongListWindowController ()

@end

@implementation SongListWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.sharedManagedObjectContext = ((RPAppDelegate *)[[NSApplication sharedApplication] delegate]).coreDataController.mainThreadContext;
    self.window.title = NSLocalizedString(@"My Favorite Songs", nil);
    self.window.backgroundColor = [NSColor colorWithDeviceRed:240.0/255.0 green:198.0/255.0 blue:150.0/255.0 alpha:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(persistentStoreChanged:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:((RPAppDelegate *)[[NSApplication sharedApplication] delegate]).coreDataController.psc];
}

- (void)persistentStoreChanged:(NSNotification *)notification
{
    DLog(@"Got notification for iCloud store changes, merging them back.");
    [self.sharedManagedObjectContext performBlock:^{
        [self.sharedManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (IBAction)deleteSong:(id)sender
{
    if(self.theTable.selectedRow != -1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setInformativeText:NSLocalizedString(@"Are you sure you want to delete the song?", nil)];
        [alert setMessageText:NSLocalizedString(@"Error", @"")];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Delete"];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    DLog(@"alertDidEnd: returncode: %ld, selectedRow: %ld", returnCode, self.theTable.selectedRow);
    if(self.theTable.selectedRow != -1 && returnCode == NSAlertSecondButtonReturn)
    {
        // Delete the managed object for the given index path
        DLog(@"Deleting song from favorites array.");
        [self.arrayController remove:self];
    }
}

- (IBAction)gotoStore:(id)sender
{
    if(self.theTable.selectedRow != -1)
    {
        Song *selectedSong =  [self.arrayController.arrangedObjects objectAtIndex:self.theTable.selectedRow];
        self.theSelectedArtist = selectedSong.artist;
        self.theSelectedTitle = selectedSong.title;
        self.theSelectedCover = selectedSong.cover;
        DLog(@"trying to get current locale setting");
        // For easy testing with other locales
        //    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
        NSString *storeCode = [locale objectForKey:NSLocaleCountryCode];
        DLog(@"Device is configured for %@", storeCode);
        // Now search for the song and quit.
        [self sendUserToStoreFor:[NSString stringWithFormat:@"%@ %@", self.theSelectedArtist, self.theSelectedTitle] onStoreCode:storeCode];
        [self.window performClose:nil];
    }
}

-(NSString *)generateAffiliateLinkFor:(NSString *)iTunesUrl andStoreCode:(NSString *)storeCode
{
    NSString *returnUrl;
    NSRange rangeForQuestionMark = [iTunesUrl rangeOfString:@"?" options:NSCaseInsensitiveSearch];
    if([storeCode caseInsensitiveCompare:@"us"] == NSOrderedSame)
    {
        // Generate a linkshare URL (use '?' o '&' a seconda se ci sia già un '?' o no)
        returnUrl = [NSString stringWithFormat:@"%@%@partnerId=30&siteID=pXVJV/M7i5Q", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else if([storeCode caseInsensitiveCompare:@"ca"] == NSOrderedSame)
    {
        // Generate a linkshare URL (use '?' o '&' a seconda se ci sia già un '?' o no)
        returnUrl = [NSString stringWithFormat:@"%@%@partnerId=30&siteID=pXVJV/M7i5Q", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else if ([storeCode caseInsensitiveCompare:@"gb"] == NSOrderedSame || [storeCode caseInsensitiveCompare:@"uk"] == NSOrderedSame)
    {
        // Generate a Tradedoubler link
        returnUrl = [NSString stringWithFormat:@"http://clkuk.tradedoubler.com/click?p=23708&a=2141801&url=%@%@partnerId=2003", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else if ([storeCode caseInsensitiveCompare:@"it"] == NSOrderedSame)
    {
        // Generate a Tradedoubler link
        returnUrl = [NSString stringWithFormat:@"http://clkuk.tradedoubler.com/click?p=24373&a=2165395&url=%@%@partnerId=2003", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else if ([storeCode caseInsensitiveCompare:@"de"] == NSOrderedSame)
    {
        // Generate a Tradedoubler link
        returnUrl = [NSString stringWithFormat:@"http://clkuk.tradedoubler.com/click?p=23761&a=2141800&url=%@%@partnerId=2003", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else if ([storeCode caseInsensitiveCompare:@"fr"] == NSOrderedSame)
    {
        // Generate a Tradedoubler link
        returnUrl = [NSString stringWithFormat:@"http://clkuk.tradedoubler.com/click?p=23753&a=2141803&url=%@%@partnerId=2003", iTunesUrl, (rangeForQuestionMark.location != NSNotFound) ? @"&" : @"?"];
    }
    else
    {
        // Simply send the user to "plain" store (without affiliate links)
        returnUrl = iTunesUrl;
    }
    returnUrl = [returnUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"Affiliate link is: <%@>", returnUrl);
    return returnUrl;
}

-(void)sendUserToStoreFor:(NSString *)searchString onStoreCode:(NSString *)storeCode
{
    NSString *searchUrl = [[[NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&country=%@&media=music&limit=1", searchString, storeCode] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"Store URL is: %@", searchUrl);
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:searchUrl]];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *res, NSData *data, NSError *err)
     {
         DLog(@" %@ ", (data) ? @"successfully." : @"with errors.");
         if(data)
         {
             // Get JSON data
             NSError *err;
             NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
             if(!jsonObject)
             {
                 NSLog(@"Error reading JSON data: %@", [err description]);
                 return;
             }
             else
             {
                 NSArray *songsData = jsonObject[@"results"];
                 if(songsData == nil || [songsData count] ==0)
                 {
                     NSLog(@"Error in JSON dictionary: %@", jsonObject);
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSAlert *alert = [[NSAlert alloc] init];
                         [alert setInformativeText:NSLocalizedString(@"The song seems to not exist on iTunes Store. You could retry after a while.", @"")];
                         [alert setMessageText:NSLocalizedString(@"Warning", @"")];
                         [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                     });
                     return;
                 }
                 NSDictionary *songData = songsData[0];
                 if(!songData)
                 {
                     NSLog(@"Error in JSON first level array: %@", songsData);
                     return;
                 }
                 DLog(@"Song data\n%@", songData);
                 NSString *songURL = songData[@"collectionViewUrl"];
                 if(!songURL)
                 {
                     songURL = songData[@"trackViewUrl"];
                     if(!songURL)
                     {
                         NSLog(@"Error in song dictionary: %@", songData);
                         return;
                     }
                 }
                 DLog(@"The requested song URL is: <%@>.", songURL);
                 NSString *affiliateLinkUrl = [self generateAffiliateLinkFor:songURL andStoreCode:storeCode];
                 DLog(@"Affiliate URL for the same is: <%@>. Calling it.", affiliateLinkUrl);
                 self.iTunesURL = [NSURL URLWithString:affiliateLinkUrl];
                 // Skip redirection engine for direct URLs
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if([self.iTunesURL.host hasSuffix:@"itunes.apple.com"])
                         [[NSWorkspace sharedWorkspace] openURL:self.iTunesURL];
                     else
                         [self openReferralURL:self.iTunesURL];
                 });
             }
         }
     }];
}

// That's Apple code from QA1629

// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL
{
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    if(!con)
        NSLog(@"Error in connecting to %@", referralURL);
}

// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    self.iTunesURL = [response URL];
    if( [self.iTunesURL.host hasSuffix:@"itunes.apple.com"])
    {
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        return nil;
    }
    else
    {
        DLog(@"Got redirected to <%@>", self.iTunesURL);
        return request;
    }
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[NSWorkspace sharedWorkspace] openURL:self.iTunesURL];
}

@end
