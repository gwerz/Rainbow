//
//  Leprechaun.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "Leprechaun.h"
#import "RainbowAppDelegate.h"
#import "LeprechaunPuncher.h"
#import <objc/runtime.h>

#define GetAppDelegate() ((RainbowAppDelegate *)[NSApp delegate])

void LMLogMessage(id<Leprechaun> module, NSString *message, BOOL isError) {
    SEL method = (isError ? @selector(logErrorString:senderName:) : @selector(logStringSimple:senderName:));
    
    [GetAppDelegate() performSelector:method withObject:message withObject:[module userPresentableName]];
}

void LMSetModuleSelectorLocked(id<Leprechaun> module, BOOL locked) {
    [GetAppDelegate() setModuleSelectorLocked:locked];
}

NSBundle *LMGetBundle(id<Leprechaun> module) {
    Class LP = objc_getClass("LeprechaunPuncher");
    return [[LP sharedInstance] bundleForModuleInstance:module];
}