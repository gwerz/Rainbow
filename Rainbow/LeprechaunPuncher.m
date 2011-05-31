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

@implementation LeprechaunPuncher

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

- (void)_setupModule:(id)module {
    [module setup];
    [[module valueForKey:@"_loaded"] release];
    [module setValue:[NSNumber numberWithBool:YES] forKey:@"_loaded"];
}

- (void)_tearDownModule:(id)module {
    [module tearDown];
    [[module valueForKey:@"_loaded"] release];
    [module setValue:[NSNumber numberWithBool:NO] forKey:@"_loaded"]; 
}

- (void)runModuleNamed:(NSString *)name {
    id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
    if(![instance isLoaded]) {
        [self _setupModule:instance];
            
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[instance requiredViewSize]];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
            
        [instance start];
    } else {
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[instance requiredViewSize]];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
    }
}

- (void)tearDownModuleNamed:(NSString *)name {
    for(NSString *name in [modules allKeys]) {
        id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
        if([instance isLoaded]) {
            [self _tearDownModule:instance];
        }
    }
}

- (NSArray *)moduleNames {
    return [[modules allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
            [instance setValue:[currentBundle retain] forKey:@"_currentBundle"];
            
            [modules setObject:[NSDictionary dictionaryWithObjectsAndKeys:instance, INSTANCE_KEY, currentBundle, BUNDLE_KEY, nil] forKey:[instance userPresentableName]];
        }
    }
    
    loadedModules = YES;
}

- (void)unloadAllModules {
    for(NSString *key in [modules allKeys]) {
        id instance = [[modules objectForKey:key] objectForKey:INSTANCE_KEY];
        if(instance != nil) {
            if([[instance valueForKey:@"_loaded"] boolValue] == YES) {
                [self _tearDownModule:instance];
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
