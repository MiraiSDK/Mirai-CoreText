//
//  CTRunDelegate-private.h
//  CoreText
//
//  Created by Chen Yonghui on 5/28/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#ifndef CoreText_CTRunDelegate_private_h
#define CoreText_CTRunDelegate_private_h

#import "CTRunDelegate.h"

typedef struct
{
    CGFloat runAscent;
    CGFloat runDescent;
    CGFloat runWidth;
}RunSize;

@interface CTRunDelegate : NSObject
@property (nonatomic, assign) CTRunDelegateCallbacks *callbacks;
@property (nonatomic, assign) void *refCon;
@property (nonatomic, assign) RunSize runSize;
@end

#endif
