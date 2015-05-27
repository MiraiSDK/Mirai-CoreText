//
//  CTRunDelegate.m
//  CoreText
//
//  Created by Chen Yonghui on 1/10/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTRunDelegate.h"

@interface CTRunDelegate()
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
    RunSize s;
    s.runAscent = callbacks->getAscent(refCon);
    s.runDescent = callbacks->getDescent(refCon);
    s.runWidth = callbacks->getWidth(refCon);
    ref.runSize = s;
    return ref;
    
}

void* CTRunDelegateGetRefCon(
                             CTRunDelegateRef runDelegate )
{
    return runDelegate.refCon;
}
