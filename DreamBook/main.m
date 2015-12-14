//
//  main.m
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[Controller instance] handleArgc:argc argv:argv];
    }
    return 0;
}