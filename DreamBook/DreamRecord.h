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
    DreamRecordStatusOther,
}
DreamRecordStatus;

@interface DreamRecord : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray<NSString *> *keyWords;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *otherInfo;

@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, retain) NSArray<NSString *> *timePoints;
@property (nonatomic, assign) DreamRecordStatus status;

@property (nonatomic, assign) NSArray<DreamRecord *> *parentDreamRecords;
@property (nonatomic, retain) NSArray<DreamRecord *> *childDreamRecords;

@end

@interface NSObject (NSDictionaryCreation)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end
