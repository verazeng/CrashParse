//
//  CrashParse.m
//  CrashParser
//
//  Created by verazeng on 14-1-7.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import "CrashParse.h"

@interface CrashParse()

@property (nonatomic) NSMutableArray *curCrashArray;
@property (nonatomic) NSString *desPath;
@property (nonatomic) NSString *desAppName;
@property (nonatomic) NSString *parsedCrashFilePath;
@property (nonatomic) NSString *curCrashFolderPath;
@end

@implementation CrashParse

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

static CrashParse *parseInstance = nil;
+ (CrashParse *)parseInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parseInstance = [[CrashParse alloc] init];
    });
    return parseInstance;
}

- (NSString *)desPath
{
    if (!_desPath) {
        _desPath = [NSHomeDirectory() stringByAppendingPathComponent:@"crashParseFolder"];
    }
    return _desPath;
}

- (NSMutableArray *)fileArray
{
    if(!_fileArray) {
        _fileArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _fileArray;
}

#pragma mark- file operation
- (BOOL)openParsedFile
{
    return [[NSWorkspace sharedWorkspace] openFile:self.parsedCrashFilePath];
}

- (void)openParseFolder
{
    [[NSWorkspace sharedWorkspace] selectFile:self.parsedCrashFilePath inFileViewerRootedAtPath:_curCrashFolderPath];
}

- (void)clearParseFolder
{
    [[NSFileManager defaultManager] removeItemAtPath:_desPath error:nil];
}

- (void)copyCrashFilesToDestPath
{
    self.desAppName = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *curFolderName = [formatter stringFromDate:[NSDate date]];
    NSString *curFolderPath = [_desPath stringByAppendingPathComponent:curFolderName];
    self.curCrashFolderPath = curFolderPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:curFolderPath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:curFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else {
        [fileManager removeItemAtPath:curFolderPath error:nil];
    }
    
    for(NSString *filePath in _fileArray) {
        NSString *fileName = [filePath lastPathComponent];
        [fileManager copyItemAtPath:filePath toPath:[curFolderPath stringByAppendingPathComponent:fileName] error:nil];
        if ([fileName pathExtension].length == 0) {
            self.desAppName = fileName;
        }
    }
    self.parsedCrashFilePath = [_curCrashFolderPath stringByAppendingPathComponent:[_desAppName stringByAppendingString:@"_parsed.crash"]];
}

- (NSString *)getCrashFile
{
    NSString *crashPath = nil;
    NSArray *existFileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_curCrashFolderPath error:nil];
    for (NSString *fileName in existFileArray) {
        if ([fileName.pathExtension isEqualToString:@"crash"]) {
            crashPath = [_curCrashFolderPath stringByAppendingPathComponent:fileName];
        }
    }
    return crashPath;
}

#pragma mark- parse operation
- (ParseResult)parse
{
    //crash文件拷贝到指定位置
    [self copyCrashFilesToDestPath];

    if (_desAppName.length == 0) {
        return eParseErrorNoAppFile;
    }
    
    //读crash数据
    NSString *crashFileName = [self getCrashFile];
    if (crashFileName.length == 0) {
        return eParseErrorNoCrashFile;
    }
    
    NSFileHandle *crashFileHandle = [NSFileHandle fileHandleForReadingAtPath:crashFileName];
    NSData *crashData = [crashFileHandle readDataToEndOfFile];
    [crashFileHandle closeFile];
    
    NSString *crashStr = [[NSString alloc] initWithData:crashData encoding:NSUTF8StringEncoding];
    NSMutableArray *crashArray = [NSMutableArray arrayWithArray:[crashStr componentsSeparatedByString:@"\n"]];
//    NSLog(@"###crash log:###\n%@",crashArray);
    BOOL isMeetThread = NO;
    for (NSInteger index = 0; index < crashArray.count; index++) {
        NSString *oneLineStr = [crashArray objectAtIndex:index];
        
        //找到第一个thread
        if (![oneLineStr hasPrefix:@"Thread"]) {
            if (!isMeetThread) {
                continue;
            }
        }
        isMeetThread = YES;
        
        //解析到Binary Images为止
        if ([oneLineStr hasPrefix:@"Binary Images:"]) {
            break;
        }
        
        //解析含有QQMusic的行
        if ([oneLineStr rangeOfString:_desAppName].length > 0) {
//            NSLog(@"###one line crash:###\n%@",oneLineStr);
            NSRange rRange = [oneLineStr rangeOfString:@"\t"];
            if (rRange.length > 0 && rRange.location + 2 < oneLineStr.length) {
                NSString *frontStr = [oneLineStr substringToIndex:rRange.location + 1];
                NSString *realAddrStr = [oneLineStr substringFromIndex:rRange.location + 1];
                NSMutableArray *onelineArray = [NSMutableArray arrayWithArray:[realAddrStr componentsSeparatedByString:@" "]];
                if (onelineArray.count >= 4) {
                    NSString *parsedLineStr = [self parseOneLineWithBaseAddr:[onelineArray objectAtIndex:1] andOffsetAddr:[onelineArray objectAtIndex:0]];
                    if (parsedLineStr.length == 0) {
                        return eParseErrorParseError;
                    }
                    NSMutableString *comParsedStr = [NSMutableString stringWithString:[onelineArray objectAtIndex:0]];
                    [comParsedStr appendString:@" "];
                    [comParsedStr appendString:parsedLineStr];
                    oneLineStr = [[frontStr stringByAppendingString:comParsedStr] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    
                    //替换解析后的crash行
                    [crashArray replaceObjectAtIndex:index withObject:oneLineStr];
                }
            }
        }
        
        //解析回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(parsingResultUpdated:)]) {
                [_delegate performSelector:@selector(parsingResultUpdated:) withObject:oneLineStr];
            }
        });
    }
    
    //解析后的数据存文件
    crashStr = [crashArray componentsJoinedByString:@"\n"];
    NSString *parseCrashFileName = self.parsedCrashFilePath;
    NSError *error;
    [crashStr writeToFile:parseCrashFileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"write error%@", error);
        return eParseErrorWriteFile;
    }
    
    return eParseSuccess;
}

//解析crashlog中的一行
- (NSString *)parseOneLineWithBaseAddr:(NSString *)baseAddrStr andOffsetAddr:(NSString *)offsetAddrStr
{
    NSString *taskPath = @"/usr/bin/atos";
    NSMutableArray *cmdArgArray = [[NSMutableArray alloc] initWithCapacity:7];
    [cmdArgArray addObject:@"-o"];
    [cmdArgArray addObject:[_curCrashFolderPath stringByAppendingPathComponent:_desAppName]];
    [cmdArgArray addObject:@"-l"];
    [cmdArgArray addObject:baseAddrStr];
    [cmdArgArray addObject:@"-arch"];
    [cmdArgArray addObject:@"armv7"];
    [cmdArgArray addObject:offsetAddrStr];
    NSString *parseResStr = [self runSystemCommandWithPath:taskPath andCmd:cmdArgArray];
    NSLog(@"####here####:\n%@", parseResStr);
    return parseResStr;
}

//使用atos解析
- (NSString *)runSystemCommandWithPath:(NSString *)tashPath andCmd:(NSArray *)cmd
{
    NSString *resultStr = @"";
    @try {
        NSPipe *outputPipe = [NSPipe pipe];
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = tashPath;
        task.arguments = cmd;
        task.standardOutput = outputPipe;
        [task launch];
        [task waitUntilExit];
        
        NSFileHandle *readHandle = [outputPipe fileHandleForReading];
        NSData *outputData = [readHandle readDataToEndOfFile];
        [readHandle closeFile];
        
        resultStr = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception){
        NSLog(@"cmd Invalid");
    }
    
    return resultStr;
}

@end
