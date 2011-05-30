//
//  LeprechaunPuncher.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "LeprechaunPuncher.h"
#import "RainbowAppDelegate.h"
#import "Leprechaun.h"

#define BUNDLE_KEY @"bundle"
#define INSTANCE_KEY @"instance"
#define TYPE_KEY @"type"

#define TYPE_ONE_CLICK 0
#define TYPE_UI 1

@implementation LeprechaunPuncher

static NSInteger cachedOneClickCount = -1;

static LeprechaunPuncher *sharedLeprechaunPuncher = nil;

+ (LeprechaunPuncher *)sharedInstance {
    @synchronized(self) {
        if (!sharedLeprechaunPuncher) {
            sharedLeprechaunPuncher = [[self alloc] init];
        }
    }
    
	return sharedLeprechaunPuncher;
}

- (id)init {
    if((self = [super init]) != nil) {
        [self reloadAllModules];
    }
    
    return self;
}

- (void)runModuleNamed:(NSString *)name {
    for(NSString *name in [modules allKeys]) {
        id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
        if(![instance isLoaded]) {
            [instance setup];
            [instance start];
        }
    }
}

- (void)tearDownModuleNamed:(NSString *)name {
    for(NSString *name in [modules allKeys]) {
        id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
        if([instance isLoaded]) {
            [instance tearDown];
        }
    }
}

- (NSInteger)oneClickModules {
    if(cachedOneClickCount != -1) {
        return cachedOneClickCount;
    }
    
    for(NSString *key in [modules allKeys]) {
        BOOL isOneClick = [[[modules objectForKey:key] objectForKey:TYPE_KEY] boolValue];
        if(isOneClick) {
            if(cachedOneClickCount == -1)
                cachedOneClickCount = 1;
            else
                cachedOneClickCount++;
        }
    }
    
    return cachedOneClickCount;
}

- (NSInteger)uiModules {
    return ([[modules allKeys] count] - [self oneClickModules]);
}

- (NSArray *)moduleNames {
    return [modules allKeys];
}

- (BOOL)moduleIsOneClickNamed:(NSString *)name {
    return ![[[modules objectForKey:name] objectForKey:TYPE_KEY] boolValue];
}

- (void)reloadAllModules {
    if(modules != nil) {
        [modules release];
    } 
    
    modules = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    for(NSString *bundleName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil]) {
        if([bundleName rangeOfString:@"bundle"].length != 0) {
            NSBundle *currentBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", resourcePath, bundleName]];
            [currentBundle load];
            
            id instance = [[[currentBundle principalClass] alloc] init];
            
            [modules setObject:[NSDictionary dictionaryWithObjectsAndKeys:instance, INSTANCE_KEY, currentBundle, BUNDLE_KEY, [NSNumber numberWithBool:[[currentBundle principalClass] isSubclassOfClass:NSClassFromString(@"LeprechaunUIModule")]], TYPE_KEY, nil] forKey:[instance userPresentableName]];
        }
    }
    
    loadedModules = YES;
}

- (void)unloadAllModules {
    for(NSString *key in [modules allKeys]) {
        id instance = [[modules objectForKey:key] objectForKey:INSTANCE_KEY];
        if(instance != nil) {
            if([[instance valueForKey:@"_loaded"] boolValue] == YES) {
                [instance tearDown];
            }
            
            [instance release];
        }
        
        NSBundle *bundle = [[modules objectForKey:key] objectForKey:BUNDLE_KEY];
        if([bundle isLoaded]) 
            [bundle unload];
    }
    
    loadedModules = NO;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {}

- (id)retain {
    return sharedLeprechaunPuncher;
}

- (id)autorelease {
    return sharedLeprechaunPuncher;
}

@end
