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

- (void)runModuleNamed:(NSString *)name;
- (void)tearDownModuleNamed:(NSString *)name;

- (BOOL)moduleIsRunning:(NSString *)name;
- (NSBundle *)bundleForModuleNamed:(NSString *)name;
- (id<Leprechaun>)instanceForModule:(NSString *)name;

- (void)addModuleFromBundle:(NSBundle *)bundle;
- (void)removeModuleNamed:(NSString *)name;

- (void)handleDeselectionOfModuleNamed:(NSString *)name;

- (void)loadAllModules;
- (void)unloadAllModules;

@end
