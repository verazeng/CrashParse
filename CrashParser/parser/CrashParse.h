//
//  CrashParse.h
//  CrashParser
//
//  Created by verazeng on 14-1-7.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ParseResult {
    eParseSuccess        = 0,  //解析成功
    eParseErrorParseError   ,  //解析出错
    eParseErrorWriteFile    ,  //写文件出错
    eParseErrorNoCrashFile  ,  //没有crash文件
    eParseErrorNoAppFile    ,  //没有app文件
} ParseResult;

@protocol ParsingDelegate <NSObject>
@optional
- (void)parsingResultUpdated:(NSString *)curParseResStr;
@end

@interface CrashParse : NSObject
@property (nonatomic) NSMutableArray *fileArray;
@property (weak) id<ParsingDelegate> delegate;

+ (CrashParse *)parseInstance;
- (ParseResult)parse;
- (void)clearParseFolder;
- (void)openParseFolder;
- (BOOL)openParsedFile;
@end


