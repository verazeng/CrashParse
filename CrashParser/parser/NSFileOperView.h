//
//  NSFileOperView.h
//  CrashParser
//
//  Created by verazeng on 14-1-15.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSFileOperView;
@protocol NSfileOperDelegate <NSObject>
@optional
- (void)deleteFileBtnClicked:(NSFileOperView *)operView;
@end

@interface NSFileOperView : NSView
@property (weak) id <NSfileOperDelegate> delegate;
@property (nonatomic) NSString *fileName;
@end
