//
//  DYOptionParser.h
//  DreamBook
//
//  Created by 段清伦 on 15/12/13.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DYOption_argument_no,
    DYOption_argument_required,
    DYOption_argument_optional,
}
DYOption_argument;

@interface DYOption : NSObject

@property (nonatomic, retain) NSString *flag;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) DYOption_argument has_arg;
@property (nonatomic, retain) NSString *opt_description;
@property (nonatomic, copy) void (^block)(DYOption *opt);

+ (DYOption *)optionWithFlag:(NSString *)flag name:(NSString *)name has_arg:(DYOption_argument)has_arg opt_description:(NSString *)opt_description block:(void (^)(DYOption *opt))block;

@end

@interface DYOptionParser : NSObject

+ (instancetype)parser;

- (BOOL)parseOptions:(NSArray<DYOption *> *)options argc:(int)argc argv:(const char **)argv error:(NSError **)error;

@end
