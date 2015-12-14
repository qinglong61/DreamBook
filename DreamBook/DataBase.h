//
//  DataBase.h
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DreamRecord.h"

@interface DataBase : NSObject

- (void)addRecord:(DreamRecord *)record;


- (void)removeRecord:(DreamRecord *)record;


- (void)updateRecord:(DreamRecord *)record;


- (DreamRecord *)selectRecordByBlock:(void (^)(void))block;

@end
