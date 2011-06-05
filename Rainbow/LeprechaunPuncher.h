//
//  LeprechaunPuncher.h
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leprechaun.h"

@interface LeprechaunPuncher : NSObject {
@private
    NSMutableDictionary *modules;
    BOOL loadedModules;
}

+ (LeprechaunPuncher *)sharedInstance;

- (NSArray *)moduleNames;
- (NSUInteger)moduleCount;

- (void)loadAllModules;
- (BOOL)loadModuleFromBundle:(NSBundle *)bundle;

- (void)removeModuleNamed:(NSString *)name permanently:(BOOL)permanently;
- (void)unloadAllModules;

- (BOOL)moduleIsStartedNamed:(NSString *)name;
- (void)startModuleNamed:(NSString *)name;

- (BOOL)moduleIsPausedNamed:(NSString *)name;
- (BOOL)moduleCanBePausedNamed:(NSString *)name;
- (void)pauseModuleNamed:(NSString *)name;

- (BOOL)moduleIsRunningNamed:(NSString *)name;
- (BOOL)moduleCanBeResumedNamed:(NSString *)name;
- (void)resumeModuleNamed:(NSString *)name;

- (void)tearDownModuleNamed:(NSString *)name;

- (BOOL)moduleExistsNamed:(NSString *)name;
- (BOOL)moduleWantsTearDownOnDeselection:(NSString *)name;

- (id<Leprechaun>)instanceForModuleNamed:(NSString *)name;
- (NSBundle *)bundleForModuleNamed:(NSString *)name;
- (NSMutableDictionary *)stateDictionaryForModuleNamed:(NSString *)name;

@end
