//
//  Controller.h
//  DreamBook
//
//  Created by 段清伦 on 15/12/12.
//  Copyright © 2015年 duanyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controller : NSObject

+ (Controller *)instance;

- (void)handleArgc:(int)argc argv:(const char **)argv;

@end
