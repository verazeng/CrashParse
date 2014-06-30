//
//  NSDragginBox.h
//  CrashParser
//
//  Created by verazeng on 14-1-14.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSFileOperView.h"

@interface NSDragginBox : NSBox <NSDraggingDestination, NSfileOperDelegate>

@end
