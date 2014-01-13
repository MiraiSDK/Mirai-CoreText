//
//  CTFoundationExtended.m
//  CoreText
//
//  Created by Chen Yonghui on 1/13/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTFoundationExtended.h"

@implementation NSAttributedString (CTExtended)
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block
{
    NSInteger idx = 0;
    NSRange effectiveRange;
    BOOL stop = NO;
    while (idx < self.length && !stop) {
        NSDictionary *attributes = [self attributesAtIndex:idx longestEffectiveRange:&effectiveRange inRange:enumerationRange];
        block(attributes,effectiveRange,&stop);
        
        idx += effectiveRange.length;
    }
    
}
@end

@implementation NSDictionary (CTExtended)
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    NSArray *allKeys = [self allKeys];
    BOOL stop = NO;
    for (id key in allKeys) {
        id obj = [self objectForKey:key];
        block(key,obj,&stop);
        if (stop) {
            break;
        }
    }
}
@end
