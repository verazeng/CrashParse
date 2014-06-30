//
//  NSDragginBox.m
//  CrashParser
//
//  Created by verazeng on 14-1-14.
//  Copyright (c) 2014年 verazeng. All rights reserved.
//

#import "NSDragginBox.h"
#import "CrashParse.h"

@implementation NSDragginBox

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourchDragMask;
    sourchDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        if (sourchDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
    if ([sender draggingSource] != self) {
        if ([[pboard types] containsObject:NSFilenamesPboardType]) {
            NSArray *fileArray = [pboard propertyListForType:NSFilenamesPboardType];
            for(NSString *filePath in fileArray) {
                if (![[CrashParse parseInstance].fileArray containsObject:filePath]) {
                    [[CrashParse parseInstance].fileArray addObject:filePath];
                    [self addFileOperSubView:filePath.lastPathComponent];
                }
            }
            NSLog(@"file array:%@", [CrashParse parseInstance].fileArray);
        }
    }
}

- (void)addFileOperSubView:(NSString *)fileName
{
    NSFileOperView *fileOperView = [[NSFileOperView alloc] initWithFrame:CGRectMake(15, 10 + ([CrashParse parseInstance].fileArray.count-1) * 22, 400, 20)];
    fileOperView.delegate = self;
    fileOperView.fileName = fileName;
    [self addSubview:fileOperView];
}

- (void)deleteFileBtnClicked:(NSFileOperView*)operView
{
    [operView removeFromSuperview];
    for (NSString *filePath in [CrashParse parseInstance].fileArray) {
        NSString *fileName = [filePath lastPathComponent];
        if ([fileName isEqualToString:operView.fileName]) {
            [[CrashParse parseInstance].fileArray removeObject:filePath];
            break;
        }
    }
    
}
@end
