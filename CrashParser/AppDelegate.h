//
//  AppDelegate.h
//  CrashParser
//
//  Created by verazeng on 14-1-7.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDragginBox.h"
#import "CrashParse.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ParsingDelegate>

@property (assign) IBOutlet NSWindow *window;
@property IBOutlet NSDragginBox *receiveFileBox;
@property IBOutlet NSButton *parserBtn;
@property IBOutlet NSButton *clearParseBufBtn;
@property IBOutlet NSButton *openBtn;
@property IBOutlet NSButton *openFolderBtn;
@property IBOutlet NSTextView *parseringTextView;
@property IBOutlet NSTextField *parserStatusTextField;

- (IBAction)onParserBtnClicked:(id)sender;
- (IBAction)onClearParseBufBtnClicked:(id)sender;
- (IBAction)onOpenBtnClicked:(id)sender;
- (IBAction)onOpenFolderBtnClicked:(id)sender;
@end
