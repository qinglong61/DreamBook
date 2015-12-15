//
//  DYOptionParser.m
//  DreamBook
//
//  Created by 段清伦 on 15/12/13.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import "DYOptionParser.h"
#import "getopt.h"

@implementation DYOption

+ (DYOption *)optionWithFlag:(NSString *)flag name:(NSString *)name has_arg:(DYOption_argument)has_arg opt_description:(NSString *)opt_description block:(void (^)(DYOption *opt))block
{
    DYOption *opt = [[DYOption alloc] init];
    opt.flag = flag;
    opt.name = name;
    opt.has_arg = has_arg;
    opt.opt_description = opt_description;
    opt.block = block;
    return opt;
}

@end

@interface DYOptionParser ()

@property (nonatomic, retain) NSMutableArray<DYOption *> *options;

@end

@implementation DYOptionParser

static DYOptionParser *parser;

+ (DYOptionParser *)parser
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[DYOptionParser alloc] init];
    });
    return parser;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.options = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)parseOptions:(NSArray *)options argc:(int)argc argv:(const char **)argv error:(NSError *__autoreleasing *)error
{
    argc = 2;
    char * argv1[2];
    argv1[0] = argv[0];
    argv1[1] = "--ta";
    
    
    [self.options addObjectsFromArray:options];
    
    if (![self containsOptHelp]) {
        DYOption *optHelp = [DYOption optionWithFlag:@"h" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(DYOption *opt) {
            printf("h\n");
            [self showUsage];
        }];
        [self.options addObject:optHelp];
    }
    
    if (![self containsOptQuestionMark]) {
        DYOption *optQuestionMark = [DYOption optionWithFlag:@"?" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(DYOption *opt) {
            printf("?\n");
            [self showUsage];
        }];
        [self.options addObject:optQuestionMark];
    }
    
    int flag = 0;
    NSMutableString *optString = [[NSMutableString alloc] init];
    struct option opts[self.options.count];
    int optIndex = 0;
    
    for (int i = 0; i < self.options.count; i++) {
        DYOption *option = self.options[i];
        if (option.flag) {
            [optString appendString:option.flag];
        }
        if (option.has_arg) {
            [optString appendString:@":"];
        }
        
        opts[i] = (struct option){
            [option.name UTF8String],
            option.has_arg,
            NULL,
            [option.flag intValue],
        };
    }
    
    flag = getopt_long(argc, (char * const *)argv1, [optString UTF8String], opts, &optIndex);
    while( flag != -1 ) {
        switch( flag ) {
            case 0:		/* long option without a short arg */
                printf("xxx\n");
                break;
                
            default:
                break;
        }
        DYOption *option = [self getOptionByFlag:[NSString stringWithUTF8String:(char *)&flag]];
        if (!option) {
            NSString *name = [NSString stringWithUTF8String:opts[optIndex].name];
            option = [self getOptionByName:name];
            printf("%s\n", [name UTF8String]);
        }
        if (option.block) {
            option.block(option);
        }
        flag = getopt_long(argc, (char * const *)argv1, [optString UTF8String], opts, &optIndex);
    }
    
    return YES;
}

- (NSString *)showUsage
{
    NSMutableString *(^trimLine)(NSMutableString *) = ^NSMutableString *(NSMutableString *line) {
        NSRange range = [line rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            line = [[line substringToIndex:range.location + 1] mutableCopy];
        }
        return line;
    };
    
    NSMutableArray *description = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"usage: %@ [options]", [NSProcessInfo processInfo].processName]];
    for (id each in self.options) {
        NSMutableString *line = [NSMutableString new];
        if ([each isKindOfClass:[DYOption class]]) {
            DYOption *option = each;
            [line appendString:@"    "];
            if (option.flag) {
                [line appendFormat:@"-%@", option.flag];
                [line appendString:option.name ? @", " : @"  "];
            } else {
                [line appendString:@"    "];
            }
            if (option.name) {
                [line appendFormat:@"--%-24@   ", option.name];
            } else {
                [line appendString:@"                             "];
            }
            if (line.length > 37) {
                line = trimLine(line);
                [line appendString:@"\n                                     "];
            }
            if (option.description) {
                [line appendString:option.description];
            }
            line = trimLine(line);
        } else {
            [line appendFormat:@"%@", each];
        }
        [description addObject:line];
    }
    return [[description componentsJoinedByString:@"\n"] stringByAppendingString:@"\n"];
}

- (BOOL)containsOptHelp
{
    for (DYOption *option in self.options) {
        if ([option.flag isEqualToString:@"h"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsOptQuestionMark
{
    for (DYOption *option in self.options) {
        if ([option.flag isEqualToString:@"?"]) {
            return YES;
        }
    }
    return NO;
}

- (DYOption *)getOptionByFlag:(NSString *)flag
{
    for (DYOption *option in self.options) {
        if ([option.flag isEqualToString:flag]) {
            return option;
        }
    }
    return nil;
}

- (DYOption *)getOptionByName:(NSString *)name
{
    for (DYOption *option in self.options) {
        if ([option.name isEqualToString:name]) {
            return option;
        }
    }
    return nil;
}

@end
