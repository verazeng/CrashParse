//
//  AppDelegate.m
//  CrashParser
//
//  Created by verazeng on 14-1-7.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self initMainWindow];
    [CrashParse parseInstance].delegate = self;
    
}

- (void)initMainWindow
{
    [_parserStatusTextField setStringValue:@""];
    [_openBtn setEnabled:NO];
    [_openFolderBtn setEnabled:NO];
    [_parseringTextView.layer setBorderColor:[NSColor lightGrayColor].CGColor];
    [_parseringTextView setEditable:NO];
}

- (void)parsingResultUpdated:(NSString *)curParseResStr
{
    [_parseringTextView setString:[NSString stringWithFormat:@"%@\n%@", _parseringTextView.string, curParseResStr]];
    if (_parseringTextView.string.length > 0) {
        [_parseringTextView scrollRangeToVisible:NSMakeRange(_parseringTextView.string.length, 0)];
    }
}

- (void)endParsing:(ParseResult)parseResult
{
    NSString *alertViewStr = nil;
    [_parserBtn setEnabled:YES];
    switch (parseResult) {
        case eParseSuccess:
        {
            [_parserStatusTextField setStringValue:@"解析成功！"];
            [_parserStatusTextField setTextColor:[NSColor blueColor]];
            [_openBtn setEnabled:YES];
            [_openFolderBtn setEnabled:YES];
        }
            break;
        case eParseErrorNoAppFile:
            alertViewStr = @"解析失败，没有应用程序包！";
            break;
        case eParseErrorNoCrashFile:
            alertViewStr = @"解析失败，没有crash文件！";
            break;
        case eParseErrorWriteFile:
            alertViewStr = @"解析失败，写文件出错！";
            break;
        case eParseErrorParseError:
            alertViewStr = @"解析失败，请确认是否安装了Command Line Tools";
        default:
            alertViewStr = @"解析失败";
            break;
    }
    
    if (alertViewStr.length > 0) {
        [_parserStatusTextField setStringValue:@"解析失败！"];
        [_parserStatusTextField setTextColor:[NSColor redColor]];
        NSAlert *alertView = [NSAlert alertWithMessageText:alertViewStr defaultButton:@"我知道了" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alertView runModal];
    }
}

- (IBAction)onParserBtnClicked:(id)sender
{
    [_parseringTextView setString:@""];
    [_parserStatusTextField setStringValue:@""];
    [_openBtn setEnabled:NO];
    [_openFolderBtn setEnabled:NO];
    
    NSUInteger fileCount = [CrashParse parseInstance].fileArray.count;
    if (fileCount < 2) {
        NSString *alertStr = nil;
        if (fileCount == 0) {
            alertStr = @"还有添加应用程序包和对应的crash文件";
        }
        else {
            alertStr = @"还有添加应用程序包或crash文件" ;
        }
        NSAlert *alertView = [NSAlert alertWithMessageText:alertStr defaultButton:@"我知道了" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alertView runModal];
        return;
    }
    
    [_parserBtn setEnabled:NO];
    [_parserStatusTextField setTextColor:[NSColor blueColor]];
    [_parserStatusTextField setStringValue:@"正在解析..."];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ParseResult result = [[CrashParse parseInstance] parse];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endParsing:result];
        });
    });
}

- (IBAction)onClearParseBufBtnClicked:(id)sender
{
    [[CrashParse parseInstance] clearParseFolder];
}

- (IBAction)onOpenBtnClicked:(id)sender
{
    [[CrashParse parseInstance] openParsedFile];
}

- (IBAction)onOpenFolderBtnClicked:(id)sender
{
    [[CrashParse parseInstance] openParseFolder];
}

@end
