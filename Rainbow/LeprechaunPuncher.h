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

- (void)removeModuleNamed:(NSString *)name;

- (NSBundle *)bundleForModuleInstance:(id<Leprechaun>)module;

- (void)handleDeselectionOfModuleNamed:(NSString *)name;

- (void)reloadAllModules;
- (void)unloadAllModules;

@end
