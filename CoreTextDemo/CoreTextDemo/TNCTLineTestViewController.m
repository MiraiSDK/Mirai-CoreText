//
//  TNCTLineTestViewController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 9/8/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNCTLineTestViewController.h"

#import "CTLineDrawTestViewController.h"
#import "CTRunDrawTestViewController.h"

@implementation TNCTLineTestViewController
+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSString *)testName
{
    return @"CTLine Test";
}

+ (NSArray *)subTests
{
    return @[[CTLineDrawTestViewController class],[CTRunDrawTestViewController class]];
}
@end
