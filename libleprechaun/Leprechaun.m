//
//  Leprechaun.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import "Leprechaun.h"
#import "RainbowAppDelegate.h"
#import "LeprechaunPuncher.h"
#import <objc/runtime.h>

#define GetLogTableHandler() ((RainbowAppDelegate *)[NSApp delegate]).logTableHelper
#define GetAppDelegate() ((RainbowAppDelegate *)[NSApp delegate])

void LMLogMessage(id<Leprechaun> module, NSString *message) {
    [GetLogTableHandler() appendLogMessage:message fromSender:[module userPresentableName]];
}

void LMSetModuleSelectorLocked(id<Leprechaun> module, BOOL locked) {
    [GetAppDelegate() setModuleSelectorLocked:locked];
}

NSBundle *LMGetBundle(id<Leprechaun> module) {
    Class LP = objc_getClass("LeprechaunPuncher");
    return [[LP sharedInstance] bundleForModuleNamed:[module userPresentableName]];
}