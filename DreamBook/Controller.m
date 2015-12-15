//
//  Controller.m
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import "Controller.h"
#import "DYOptionParser.h"

@interface Controller ()

@property (nonatomic, retain) NSArray *options;

@end

@implementation Controller

static Controller *instance;

+ (Controller *)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Controller alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        DYOption *optAdd = [DYOption optionWithFlag:@"a" name:@"add" has_arg:DYOption_argument_no opt_description:@"add one record" block:^(DYOption *opt) {
            printf("a\n");
        }];
        DYOption *optName = [DYOption optionWithFlag:@"n" name:@"name" has_arg:DYOption_argument_required opt_description:@"name of the record" block:^(DYOption *opt) {
            printf("n\n");
        }];
        DYOption *optContent = [DYOption optionWithFlag:@"c" name:@"content" has_arg:DYOption_argument_required opt_description:@"content of the record" block:^(DYOption *opt) {
            printf("c\n");
        }];
        DYOption *optkeywords = [DYOption optionWithFlag:@"k" name:@"keywords" has_arg:DYOption_argument_required opt_description:@"keywords of the record" block:^(DYOption *opt) {
            printf("k\n");
        }];
        DYOption *optParent = [DYOption optionWithFlag:@"p" name:@"parent" has_arg:DYOption_argument_required opt_description:@"parentRecord of the record" block:^(DYOption *opt) {
            printf("p\n");
        }];
        DYOption *optOther = [DYOption optionWithFlag:@"o" name:@"otherInfo" has_arg:DYOption_argument_required opt_description:@"otherInfo of the record" block:^(DYOption *opt) {
            printf("o\n");
        }];
        DYOption *optLongOnly = [DYOption optionWithFlag:nil name:@"test" has_arg:DYOption_argument_no opt_description:@"longOnly" block:^(DYOption *opt) {
            printf("0\n");
        }];
        self.options = [NSArray arrayWithObjects:optAdd, optName, optContent, optkeywords, optParent, optOther, optLongOnly, nil];
    }
    return self;
}

- (void)handleArgc:(int)argc argv:(const char **)argv
{
    [[DYOptionParser parser] parseOptions:self.options argc:argc argv:argv error:NULL];
}

@end