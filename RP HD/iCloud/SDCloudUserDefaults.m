//
//  SDCloudUserDefaults.m
//
//  Created by Stephen Darlington on 01/09/2011.
//  Copyright (c) 2011 Wandle Software Limited. All rights reserved.
//

#import "SDCloudUserDefaults.h"

@implementation SDCloudUserDefaults

+(NSString*)stringForKey:(NSString*)aKey {
    return [SDCloudUserDefaults objectForKey:aKey];
}

+(BOOL)boolForKey:(NSString*)aKey {
    return [[SDCloudUserDefaults objectForKey:aKey] boolValue];
}

+(id)objectForKey:(NSString*)aKey {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    id retv;
    if(kv)
    {
        NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
        retv = [cloud objectForKey:aKey];
        if (!retv) {
            retv = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
            [cloud setObject:retv forKey:aKey];
        }
    }
    else
        retv = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    return retv;
}

+(NSArray *)arrayForKey:(NSString *)aKey
{
    NSArray *retv;
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
    {
        NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
        retv = [cloud arrayForKey:aKey];
        if (!retv) 
        {
            retv = [[NSUserDefaults standardUserDefaults] arrayForKey:aKey];
            [cloud setArray:retv forKey:aKey];
        }
    }
    else {
        retv = [[NSUserDefaults standardUserDefaults] arrayForKey:aKey];
    }
    return retv;    
}

+(void)setString:(NSString*)aString forKey:(NSString*)aKey {
    [SDCloudUserDefaults setObject:aString forKey:aKey];
}

+(void)setBool:(BOOL)aBool forKey:(NSString*)aKey {
    [SDCloudUserDefaults setObject:[NSNumber numberWithBool:aBool] forKey:aKey];
}

+(void)setObject:(id)anObject forKey:(NSString*)aKey {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSUbiquitousKeyValueStore defaultStore] setObject:anObject forKey:aKey];
    [[NSUserDefaults standardUserDefaults] setObject:anObject forKey:aKey];
}

+(void)setArray:(NSArray *)anArray forKey:(NSString *)aKey
{
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSUbiquitousKeyValueStore defaultStore] setArray:anArray forKey:aKey];
    [[NSUserDefaults standardUserDefaults] setObject:anArray forKey:aKey];
}

+(void)removeObjectForKey:(NSString*)aKey {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:aKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:aKey];
}

+(void)synchronize {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)registerForNotifications {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSNotificationCenter defaultCenter] addObserverForName:@"NSUbiquitousKeyValueStoreDidChangeExternallyNotification"
                                                          object:[NSUbiquitousKeyValueStore defaultStore]
                                                           queue:nil
                                                      usingBlock:^(NSNotification* notification) {
                                                          NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                                          NSUbiquitousKeyValueStore* cloud = [NSUbiquitousKeyValueStore defaultStore];
                                                          NSDictionary* changedKeys = [notification.userInfo objectForKey:@"NSUbiquitousKeyValueStoreChangedKeysKey"];
                                                          for (NSString* a in changedKeys) {
                                                              [defaults setObject:[cloud objectForKey:a] forKey:a];
                                                          }
                                                      }];
}

+(void)removeNotifications {
    Class kv = NSClassFromString(@"NSUbiquitousKeyValueStore");
    if(kv)
        [[NSNotificationCenter defaultCenter] removeObserver:[NSUbiquitousKeyValueStore defaultStore]];
}

@end
