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
#import <objc/runtime.h>

#define BUNDLE_KEY @"bundle"
#define INSTANCE_KEY @"instance"
#define STATE_KEY @"state"
#define STATE_SETUP_KEY @"setup"
#define STATE_STARTED_KEY @"started"
#define STATE_PAUSE_RESUME_KEY @"pause_resume"

#define STATE_PAUSED 1
#define STATE_RESUMED 2

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

- (NSArray *)moduleNames {
    return [[modules allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSUInteger)moduleCount {
    return [[self moduleNames] count];
}

- (void)loadAllModules {
    if(loadedModules) return;
    
    modules = [[NSMutableDictionary dictionaryWithCapacity:0] retain];
    
    for(NSString *bundlePath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Contents/PlugIns", [[NSBundle mainBundle] bundlePath]] error:nil]) {
        NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Contents/PlugIns/%@", [[NSBundle mainBundle] bundlePath], bundlePath]];
        
        [self loadModuleFromBundle:bundle];
    }
    
    loadedModules = YES;
}

- (BOOL)loadModuleFromBundle:(NSBundle *)bundle {
    if(bundle == nil) return NO;
    
    if(![bundle isLoaded]) {
        [bundle load];
    }
    
    Class moduleClass = [bundle principalClass];
    if(!class_conformsToProtocol(moduleClass, @protocol(Leprechaun))) {
        [[NSFileManager defaultManager] removeItemAtPath:[bundle bundlePath] error:nil];
        return NO;
    }
    
    id<Leprechaun> instance = [[[moduleClass alloc] init] autorelease];
    [instance setup];
    
    [modules setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        bundle, BUNDLE_KEY,
                        instance, INSTANCE_KEY,
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],  STATE_STARTED_KEY, [NSNumber numberWithBool:YES], STATE_SETUP_KEY, nil], STATE_KEY, nil] forKey:[[instance userPresentableName] autorelease]];
    
    return YES;
}

- (void)removeModuleNamed:(NSString *)name permanently:(BOOL)permanently {
    NSBundle *bundle = [self bundleForModuleNamed:name];
    
    [self tearDownModuleNamed:name];
    [modules removeObjectForKey:name];
    
    if(permanently) {
        [[NSFileManager defaultManager] removeItemAtPath:[bundle bundlePath] error:nil];
    }
}

- (void)unloadAllModules {
    for(NSString *name in [modules allKeys]) {
        [self removeModuleNamed:name permanently:NO];
    }
    
    loadedModules = NO;
}

- (BOOL)moduleIsStartedNamed:(NSString *)name {
    return [[[self stateDictionaryForModuleNamed:name] objectForKey:STATE_STARTED_KEY] boolValue];
}

- (void)startModuleNamed:(NSString *)name {
    if([self moduleIsStartedNamed:name]) return;
    
    id<Leprechaun> instance = [self instanceForModuleNamed:name];
    [instance start];
    
    [[self stateDictionaryForModuleNamed:name] setObject:[NSNumber numberWithBool:YES] forKey:STATE_STARTED_KEY];
}

- (BOOL)moduleIsPausedNamed:(NSString *)name {
    return ([[[self stateDictionaryForModuleNamed:name] objectForKey:STATE_PAUSE_RESUME_KEY] intValue] == STATE_PAUSED);
}

- (BOOL)moduleCanBePausedNamed:(NSString *)name {
    return ![[self instanceForModuleNamed:name] shouldTearDownOnDeselection];
}

- (void)pauseModuleNamed:(NSString *)name {
    if([self moduleIsPausedNamed:name] || ![self moduleCanBePausedNamed:name]) return;
    
    id<Leprechaun> instance = [self instanceForModuleNamed:name];
    if([instance respondsToSelector:@selector(handleDeselectionByUser)])
        [instance handleDeselectionByUser];
    
    [[self stateDictionaryForModuleNamed:name] setObject:[NSNumber numberWithInt:STATE_PAUSED] forKey:STATE_PAUSE_RESUME_KEY];
}

- (BOOL)moduleIsRunningNamed:(NSString *)name {
    return ([[[self stateDictionaryForModuleNamed:name] objectForKey:STATE_PAUSE_RESUME_KEY] intValue] == STATE_RESUMED);
}

- (BOOL)moduleCanBeResumedNamed:(NSString *)name {
    return ![[self instanceForModuleNamed:name] shouldTearDownOnDeselection];
}

- (void)resumeModuleNamed:(NSString *)name {
    if([self moduleIsRunningNamed:name] || ![self moduleCanBeResumedNamed:name]) return;
    
    id<Leprechaun> instance = [self instanceForModuleNamed:name];
    if([instance respondsToSelector:@selector(handleReselectionByUser)])
        [instance handleReselectionByUser];
    
    [[self stateDictionaryForModuleNamed:name] setObject:[NSNumber numberWithInt:STATE_RESUMED] forKey:STATE_PAUSE_RESUME_KEY];
}

- (void)tearDownModuleNamed:(NSString *)name {
    if(![[[self stateDictionaryForModuleNamed:name] objectForKey:STATE_SETUP_KEY] boolValue]) return;
    
    id<Leprechaun> instance = [self instanceForModuleNamed:name];
    [instance tearDown];
    
    [[self stateDictionaryForModuleNamed:name] setObject:[NSNumber numberWithBool:NO] forKey:STATE_STARTED_KEY];
    [[self stateDictionaryForModuleNamed:name] removeObjectForKey:STATE_PAUSE_RESUME_KEY];
}

- (BOOL)moduleExistsNamed:(NSString *)name {
    return [modules objectForKey:name] != nil;
}

- (id<Leprechaun>)instanceForModuleNamed:(NSString *)name {
    return [[modules objectForKey:name] objectForKey:INSTANCE_KEY];
}

- (NSBundle *)bundleForModuleNamed:(NSString *)name {
    return [[modules objectForKey:name] objectForKey:BUNDLE_KEY];
}

- (NSMutableDictionary *)stateDictionaryForModuleNamed:(NSString *)name {
    return [[modules objectForKey:name] objectForKey:STATE_KEY];
}
            
- (BOOL)moduleWantsTearDownOnDeselection:(NSString *)name {
    return [[self instanceForModuleNamed:name] shouldTearDownOnDeselection];
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
