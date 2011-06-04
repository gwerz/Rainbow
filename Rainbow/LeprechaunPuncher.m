//
//  LeprechaunPuncher.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import "LeprechaunPuncher.h"
#import "RainbowAppDelegate.h"
#import "Leprechaun.h"
#import "LogTableHelper.h"

#define BUNDLE_KEY @"bundle"
#define INSTANCE_KEY @"instance"
#define LOADSTATE_KEY @"loadstate"

#define GetAppDelegate() ((RainbowAppDelegate *)[NSApp delegate])
#define GetLogTableHandler() ((RainbowAppDelegate *)[NSApp delegate]).logTableHelper

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
        modules = nil;
        loadedModules = NO;
    }
    
    return self;
}

- (void)_setupModule:(id)module {
    [module setup];
    [[modules objectForKey:[module userPresentableName]] setObject:[NSNumber numberWithBool:YES] forKey:LOADSTATE_KEY];
}

- (void)_tearDownModule:(id)module {
    [module tearDown];
    [[modules objectForKey:[module userPresentableName]] setObject:[NSNumber numberWithBool:NO] forKey:LOADSTATE_KEY];
}

- (void)runModuleNamed:(NSString *)name {
    id instance = [self instanceForModule:name];
    if(![self moduleIsRunning:name]) {
        [self _setupModule:instance];
            
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[[instance rootView] frame].size];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
            
        [((RainbowAppDelegate *)[NSApp delegate]).logTableHelper appendLogMessage:[NSString stringWithFormat:@"Running %@", name] fromSender:@"LeprechaunLoader"];
        
        [instance start];
    } else {
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[[instance rootView] frame].size];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
    }
}

- (void)tearDownModuleNamed:(NSString *)name {
    for(NSString *name in [modules allKeys]) {
        id instance = [self instanceForModule:name];
        
        if([self moduleIsRunning:name]) {
            [((RainbowAppDelegate *)[NSApp delegate]).logTableHelper appendLogMessage:[NSString stringWithFormat:@"Stopping %@", name] fromSender:@"LeprechaunLoader"];
            
            [self _tearDownModule:instance];
        }
    }
}

- (void)addModuleFromBundle:(NSBundle *)bundle {
    if(![bundle isLoaded]) {
        [bundle load];
    }
    
    id instance = [[[bundle principalClass] alloc] init];
    if(![instance conformsToProtocol:@protocol(Leprechaun)]) {
        [((RainbowAppDelegate *)[NSApp delegate]).logTableHelper appendLogMessage:[NSString stringWithFormat:@"ERROR: Could not load module. Class %@ does not conform to Leprechaun protocol", NSStringFromClass([bundle principalClass])] fromSender:@"LeprechaunLoader"];
        [instance release];
    } else {
        [modules setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[instance autorelease], INSTANCE_KEY, bundle, BUNDLE_KEY, nil] forKey:[[[instance userPresentableName] copy] autorelease]];
    }
}

- (NSArray *)moduleNames {
    return [[modules allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)loadAllModules {
    modules = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *resourcePath = [[NSBundle mainBundle] bundlePath];
    NSString *bundlesPath = [[resourcePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"PlugIns"];
    
    NSArray *bundles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlesPath error:nil];
    
    for(NSString *bundleName in bundles) {
        if([bundleName rangeOfString:@"bundle"].length != 0) {
            NSBundle *currentBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", bundlesPath, bundleName]];
            
            [self addModuleFromBundle:currentBundle];
        }
    }
    
    loadedModules = YES;
}

- (void)unloadAllModules {
    for(NSString *key in [modules allKeys]) {
        [self tearDownModuleNamed:key];
        
        [modules removeObjectForKey:key];
    }
    
    [modules release];
    
    loadedModules = NO;
}

- (id<Leprechaun>)instanceForModule:(NSString *)name {
    return [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
}

- (BOOL)moduleIsRunning:(NSString *)name {
    return [[[modules objectForKey:name] objectForKey:LOADSTATE_KEY] boolValue];
}

- (void)removeModuleNamed:(NSString *)name {
    [self tearDownModuleNamed:name];

    NSString *path = [[self bundleForModuleNamed:name] bundlePath];
    
    [modules removeObjectForKey:name];
    
    NSLog(@"Remove: %d", [[NSFileManager defaultManager] removeItemAtPath:path error:NULL]);
}

- (void)handleDeselectionOfModuleNamed:(NSString *)name {
    id instance = [self instanceForModule:name];
    
    if([instance shouldBeKilledOnDeselection]) {
        [self tearDownModuleNamed:name];
    }
}

- (NSBundle *)bundleForModuleNamed:(NSString *)name {
    return [[modules objectForKey:name] objectForKey:BUNDLE_KEY];
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
