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
    [self.options addObjectsFromArray:options];
    
    if (![self containsOptHelp]) {
        DYOption *optHelp = [DYOption optionWithFlag:@"h" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(DYOption *opt) {
            
        }];
        [self.options addObject:optHelp];
    }
    
    if (![self containsOptQuestionMark]) {
        DYOption *optQuestionMark = [DYOption optionWithFlag:@"?" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(DYOption *opt) {
            
        }];
        [self.options addObject:optQuestionMark];
    }
    
    int flag = 0;
    NSMutableString *optString = [[NSMutableString alloc] init];
    struct option opts[options.count];
    int optIndex = 0;
    
    for (int i = 0; i < options.count; i++) {
        DYOption *option = options[i];
        [optString appendString:option.flag];
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
    
    flag = getopt_long(argc, (char * const *)argv, [optString UTF8String], opts, &optIndex);
    while( flag != -1 ) {
        switch( flag ) {
            case 'h':   /* fall-through is intentional */
            case '?':
                [self showUsage];
                break;
                
            case 0:		/* long option without a short arg */
                break;
                
            default:
                break;
        }
        DYOption *option = [self getOptionByFlag:[NSString stringWithUTF8String:(char *)&flag]];
        if (!option) {
            option = [self getOptionByName:@""];
        }
        if (option.block) {
            option.block(option);
        }
        flag = getopt_long(argc, (char * const *)argv, [optString UTF8String], opts, &optIndex);
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
    
    NSMutableArray *description = [NSMutableArray arrayWithObject:@""];
    for (id each in self.options) {
        NSMutableString *line = [NSMutableString new];
        if ([each isKindOfClass:[DYOption class]]) {
            DYOption *option = each;
            [line appendString:@"    "];
            if (option.flag) {
                [line appendFormat:@"-%c", option.flag];
                [line appendString:option.name ? @", " : @"  "];
            } else {
                [line appendString:@"    "];
            }
            if (option.name) {
                [line appendFormat:@"--%-24s   ", option.name];
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
