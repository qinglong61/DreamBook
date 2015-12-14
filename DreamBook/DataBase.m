//
//  DataBase.m
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import "DataBase.h"
#import "DreamRecord.h"

@interface DataBase ()

@property (nonatomic, retain) DreamRecord *rootRecord;

@end

@implementation DataBase

- (void)addRecord:(DreamRecord *)record
{

}

- (void)removeRecord:(DreamRecord *)record
{

}

- (void)updateRecord:(DreamRecord *)record
{

}

- (DreamRecord *)selectRecordByBlock:(void (^)(void))block
{
    return nil;
}

#pragma mark - persistence

- (void)sync
{
//    DreamRecord *rootRecord = [self read];
//    rootRecord.childDreamRecords = [NSArray arrayWithObject:self.rootRecord];
    [self write];
}

- (void)write
{
    NSDictionary *dic = [self.rootRecord dictionary];
    [dic writeToFile:[self storePath] atomically:YES];
}

- (DreamRecord *)read
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[self storePath]];
    return [[DreamRecord alloc] initWithDictionary:dic];
}

- (NSString *)storePath
{
    NSString *path = [NSString pathWithComponents:@[NSHomeDirectory(), @"360云盘", @".DreamBook"]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    return [path stringByAppendingPathComponent:[self fileName]];
}

- (NSString *)fileName
{
    return @"DreamBook";
}

@end
