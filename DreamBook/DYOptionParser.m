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

+ (DYOption *)optionWithFlag:(NSString *)flag name:(NSString *)name has_arg:(DYOption_argument)has_arg opt_description:(NSString *)opt_description block:(DYOptionBlock)block
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

- (BOOL)parseOptions:(NSArray<DYOption *> *)options argc:(int)argc argv:(const char **)argv error:(NSError *__autoreleasing *)error
{
    [self.options removeAllObjects];
    [self.options addObjectsFromArray:options];
    
    [self.options sortUsingComparator:^NSComparisonResult(DYOption *opt1, DYOption *opt2) {
        return [opt1.flag compare:opt2.flag];
    }];
    
    if (![self containsOptHelp]) {
        DYOption *optHelp = [DYOption optionWithFlag:@"h" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(NSArray<NSString *> *args) {
            [self showUsage];
        }];
        [self.options addObject:optHelp];
    }
    
    if (![self containsOptQuestionMark]) {
        DYOption *optQuestionMark = [DYOption optionWithFlag:@"?" name:@"help" has_arg:DYOption_argument_no opt_description:@"help" block:^(NSArray<NSString *> *args) {
            [self showUsage];
        }];
        [self.options addObject:optQuestionMark];
    }
    
    int flag = 0;
    NSMutableString *optString = [[NSMutableString alloc] init];
    struct option * opts = malloc((self.options.count + 1) * sizeof(struct option));
    
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
    
    while ( (flag = getopt_long(argc, (char * const *)argv, [optString UTF8String], opts, &optIndex)) != -1 )
    {
//        printf("[optIndex]=%d\n", optIndex);
//        
//        printf("[optarg]=%s\n", optarg);
//        printf("[optind]=%d\n", optind);
//        printf("[args]=%s\n", argv[optind-1]);
//        
//        printf("[flag]=%c\n", flag);
//        printf("[opterr]=%d\n", opterr);
//        printf("[optopt]=%c\n", optopt);
//        printf("[optreset]=%d\n", optreset);
        
        if (opterr && flag=='?') {
            NSString *errInfo = [NSString stringWithFormat:@"%@: invalid option %s", [NSProcessInfo processInfo].processName, argv[optind-1]];
            *error = [NSError errorWithDomain:@"DYOptionParserDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: errInfo}];
        }
        
        DYOption *option = [self getOptionByFlag:[NSString stringWithUTF8String:(char *)&flag]];
        if (!option) {
            NSString *name = [NSString stringWithUTF8String:opts[optIndex].name];
            option = [self getOptionByName:name];
        }
        
        if (option.has_arg) {
            NSMutableArray *args = [[NSMutableArray alloc] init];
            for (int i = optind-1; argv[i][0] != '-'; i++) {
                [args addObject:[NSString stringWithUTF8String:argv[i]]];
            }
            if (option.block) {
                option.block(args);
            }
        } else {
            if (option.block) {
                option.block(NULL);
            }
        }
    }
    
    return YES;
}

- (void)showUsage
{
    NSUInteger maxNameLength = 0;
    for (DYOption *option in self.options) {
        if (option.name.length > maxNameLength) {
            maxNameLength = option.name.length;
        }
    }
    
    NSMutableString *usage = [NSMutableString stringWithFormat:@"usage: %@ -options\n", [NSProcessInfo processInfo].processName];
    for (DYOption *option in self.options) {
        NSMutableString *line = [NSMutableString new];
        [line appendString:@"    "];
        if (option.flag) {
            [line appendFormat:@"-%@", option.flag];
            [line appendString:option.name ? @", " : @"  "];
        } else {
            [line appendString:@"    "];
        }
        if (option.name) {
            [line appendFormat:@"--%@ ", option.name];
        } else {
            [line appendString:@"     "];
        }
        if (option.has_arg) {
            [line appendString:@"[...] "];
        } else {
            [line appendString:@"      "];
        }
        for (int i = 0; i < maxNameLength - option.name.length + 1; i++) {
            [line appendString:@" "];
        }
        if (option.description) {
            [line appendString:[NSString stringWithFormat:@"\"%@\"", option.opt_description]];
        }
        [usage appendString:line];
        [usage appendString:@"\n"];
    }
    printf("%s\n", [usage UTF8String]);
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
