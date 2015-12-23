//
//  DreamRecord.h
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DreamRecordStatusToDo,
    DreamRecordStatusDoing,
    DreamRecordStatusDone,
    DreamRecordStatusPause,
    DreamRecordStatusCancel,
    DreamRecordStatusOther
}
DreamRecordStatus;

@interface DreamRecordEvent : NSObject

@property (nonatomic, assign) DreamRecordStatus status;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@interface DreamRecord : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray<NSString *> *keyWords;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *otherInfo;

@property (nonatomic, assign, readonly) NSUInteger identity;
@property (nonatomic, retain, readonly) NSArray<DreamRecordEvent *> *history;

@property (nonatomic, assign) NSArray<DreamRecord *> *parentDreamRecords;
@property (nonatomic, retain, readonly) NSArray<DreamRecord *> *childDreamRecords;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name
                     content:(NSString *)content
                    KeyWords:(NSArray<NSString *> *)keyWords
                   otherInfo:(NSString *)otherInfo
          parentDreamRecords:(NSArray<DreamRecord *> *)parentDreamRecords;

@end

@interface NSObject (NSDictionaryCreation)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end
