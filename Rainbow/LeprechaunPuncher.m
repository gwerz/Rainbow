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

#define BUNDLE_KEY @"bundle"
#define INSTANCE_KEY @"instance"
#define LOADSTATE_KEY @"loadstate"

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
        
        [self reloadAllModules];
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
    id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
    if(![[[modules objectForKey:[instance userPresentableName]] objectForKey:LOADSTATE_KEY] boolValue]) {
        [self _setupModule:instance];
            
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[[instance rootView] frame].size];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
            
        [instance start];
    } else {
        [((RainbowAppDelegate *)[NSApp delegate]) resizeModuleViewToSize:[[instance rootView] frame].size];
        [((RainbowAppDelegate *)[NSApp delegate]) setCurrentModuleView:[instance rootView]];
    }
}

- (void)tearDownModuleNamed:(NSString *)name {
    for(NSString *name in [modules allKeys]) {
        id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
        if([[[modules objectForKey:[instance userPresentableName]] objectForKey:LOADSTATE_KEY] boolValue]) {
            [self _tearDownModule:instance];
        }
    }
}

- (NSArray *)moduleNames {
    return [[modules allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)reloadAllModules {
    if(modules != nil) {
        for(NSString *key in [modules allKeys]) {
            if([[[modules objectForKey:key] objectForKey:LOADSTATE_KEY] boolValue] == YES) {
                id instance = [[modules objectForKey:key] objectForKey:INSTANCE_KEY];
                [self _tearDownModule:instance];
                [instance release];
            }
            
            NSBundle *bundle = [[modules objectForKey:key] objectForKey:BUNDLE_KEY];
            if([bundle isLoaded]) 
                [bundle unload];
        }
        
        [modules release];
    } 
    
    modules = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *resourcePath = [[NSBundle mainBundle] bundlePath];
    NSString *bundlesPath = [[resourcePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"PlugIns"];
    
    NSArray *bundles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlesPath error:nil];
    
    for(NSString *bundleName in bundles) {
        if([bundleName rangeOfString:@"bundle"].length != 0) {
            NSBundle *currentBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", bundlesPath, bundleName]];
            [currentBundle load];
            
            id instance = [[[currentBundle principalClass] alloc] init];
            if(![instance conformsToProtocol:@protocol(Leprechaun)]) {
                [instance release];
                [currentBundle unload];
            } else {
                [modules setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:instance, INSTANCE_KEY, currentBundle, BUNDLE_KEY, nil] forKey:[[[instance userPresentableName] copy] autorelease]];
                
               // [modules setObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:instance, INSTANCE_KEY, [currentBundle retain], BUNDLE_KEY, nil] forKey:[[instance userPresentableName] copy]];
            }
        }
    }
    
    loadedModules = YES;
    
    [((RainbowAppDelegate *)[NSApp delegate]) performSelector:@selector(reloadTable)];
}

- (void)unloadAllModules {
    for(NSString *key in [modules allKeys]) {
        id instance = [[modules objectForKey:key] objectForKey:INSTANCE_KEY];
        if(instance != nil) {
            [instance release];
        }
        
        NSBundle *bundle = [[modules objectForKey:key] objectForKey:BUNDLE_KEY];
        if([bundle isLoaded]) 
            [bundle unload];
    }
    
    loadedModules = NO;
}

- (void)removeModuleNamed:(NSString *)name {
    NSLog(@"I hate you");
    id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
    
    if([[[modules objectForKey:name] objectForKey:LOADSTATE_KEY] boolValue] == YES) {
        [self _tearDownModule:instance];
    }
    
    [instance release];
    
    NSBundle *bundle = [[modules objectForKey:name] objectForKey:BUNDLE_KEY];
    [[modules objectForKey:name] removeAllObjects];
    
    [modules removeObjectForKey:name];
    
    if([bundle isLoaded]) {
        [bundle unload];
    }
        
    //[((RainbowAppDelegate *)[NSApp delegate]) performSelector:@selector(reloadTable)];
}

- (void)handleDeselectionOfModuleNamed:(NSString *)name {
    id instance = [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
    
    if([instance shouldBeKilledOnDeselection]) {
        [self _tearDownModule:instance];
    }
}

- (NSBundle *)bundleForModuleInstance:(id<Leprechaun>)module {
    return [[modules objectForKey:[module userPresentableName]] objectForKey:BUNDLE_KEY];
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
