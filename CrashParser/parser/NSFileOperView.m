//
//  NSFileOperView.m
//  CrashParser
//
//  Created by verazeng on 14-1-15.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import "NSFileOperView.h"

@interface NSFileOperView()
@property (nonatomic) NSTextField *fileNameText;
@property (nonatomic) NSButton *closeBtn;
@end

@implementation NSFileOperView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSTextField *fileTextField = [[NSTextField alloc] initWithFrame:self.bounds];
        fileTextField.backgroundColor = [NSColor lightGrayColor];
        fileTextField.textColor = [NSColor whiteColor];
        fileTextField.font = [NSFont systemFontOfSize:13.0f];
        [fileTextField setBordered:NO];
        self.fileNameText = fileTextField;
        [self addSubview:fileTextField];
        
        NSImage *image = [NSImage imageNamed:@"close"];
        NSButton *closeBtn = [[NSButton alloc] initWithFrame:CGRectMake(0, 2, image.size.width, image.size.height)];
        closeBtn.image = image;
        [closeBtn setBordered:NO];
        [closeBtn setTarget:self];
        [closeBtn setAction:@selector(performClick:)];
        self.closeBtn = closeBtn;
        [self addSubview:closeBtn];
    }
    return self;
}

- (void)setFileName:(NSString *)fileName
{
    if ([_fileName isEqual:fileName]) {
        return;
    }
    
    _fileName = fileName;
    [_fileNameText setStringValue:fileName];
    CGSize size = [fileName boundingRectWithSize:NSMakeSize(300, 30) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_fileNameText.font}].size;
    CGRect fileTextFrame = _fileNameText.frame;
    fileTextFrame.size.width = size.width + 8;
    _fileNameText.frame = fileTextFrame;
    
    CGRect closeBtnFrame = _closeBtn.frame;
    closeBtnFrame.origin.x = fileTextFrame.size.width + 5;
    _closeBtn.frame = closeBtnFrame;
}

- (void)performClick:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteFileBtnClicked:)]) {
        [self.delegate performSelector:@selector(deleteFileBtnClicked:) withObject:self];
    }
}

@end
