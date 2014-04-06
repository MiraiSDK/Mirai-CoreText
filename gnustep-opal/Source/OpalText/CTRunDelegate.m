//
//  CTRunDelegate.m
//  CoreText
//
//  Created by Chen Yonghui on 1/10/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTRunDelegate.h"

@interface CTRunDelegate : NSObject
@property (nonatomic, assign) CTRunDelegateCallbacks *callbacks;
@property (nonatomic, assign) void *refCon;

@end

@implementation CTRunDelegate

@end

CTRunDelegateRef CTRunDelegateCreate(
                                     const CTRunDelegateCallbacks* callbacks,
                                     void* refCon )
{
    CTRunDelegateRef ref = [[CTRunDelegate alloc] init];
    ref.callbacks = callbacks;
    ref.refCon = refCon;
    return ref;
    
}

void* CTRunDelegateGetRefCon(
                             CTRunDelegateRef runDelegate )
{
    return runDelegate.refCon;
}
