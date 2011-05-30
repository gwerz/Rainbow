//
//  RainbowAppDelegate.m
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "RainbowAppDelegate.h"

@implementation RainbowAppDelegate

@synthesize window, logView, logDrawer, progressBar, progressLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [logView setEditable:NO];
    [logDrawer open:self];
    progressBarVisible = NO;
    
    [self logString:@"Welcome to Rainbow, the most powerful iDevice utility!" color:[NSColor blueColor] fontSize:16];
}

- (void)logString:(NSString *)string color:(NSColor *)color fontSize:(CGFloat)size {
    NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
    [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:size] range:NSMakeRange(0, [string length])];
    [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [string length])];
    
    NSTextStorage *storage = [logView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:str];
    [storage endEditing];
    
    [logView scrollToEndOfDocument:nil];
}

- (void)logStringSimple:(NSString *)string {
    NSTextStorage *storage = [logView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:[[[NSAttributedString alloc] initWithString:string] autorelease]];
    [storage endEditing];
     
     [logView scrollToEndOfDocument:nil];
}

- (void)showProgressBar:(BOOL)show animated:(BOOL)animated {
    
}

- (void)setModuleSelectorLocked:(BOOL)locked {
    [tableScrollView setEnabled:!locked];
}

@end
