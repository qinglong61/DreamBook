//
//  DreamRecord.m
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import "DreamRecord.h"
#import <objc/runtime.h>

@implementation NSObject (NSDictionaryCreation)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    NSMutableArray *keys = [NSMutableArray array];
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        [keys addObject:propertyName];
    }
    free(properties);
    return [self dictionaryWithValuesForKeys:keys];
}

@end

@implementation DreamRecord

@end
