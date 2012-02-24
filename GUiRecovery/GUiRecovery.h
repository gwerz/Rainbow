//
//  GUiRecovery.h
//  GUiRecovery
//
//  Created by John Heaton on 6/4/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leprechaun.h"
#import "libirecovery.h"


@interface GUiRecovery : NSObject <Leprechaun> {
@private
    NSViewController *rootViewController;
   // irecv_client_t client;
}

@property (nonatomic, assign) IBOutlet NSViewController *rootViewController;

@end
