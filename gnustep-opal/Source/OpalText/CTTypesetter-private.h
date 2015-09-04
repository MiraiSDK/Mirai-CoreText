//
//  CTTypesetter-private.h
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#include <CoreText/CTTypesetter.h>
#include <CoreText/CTRunDelegate.h>

/* Classes */

/**
 * Typesetter
 */
@interface CTTypesetter : NSObject
{
    NSAttributedString *_as;
    NSDictionary *_options;
    
}

- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options;

- (CTLineRef)createLineWithRange: (CFRange)range;
- (CFIndex)suggestClusterBreakAtIndex: (CFIndex)start
                                width: (double)width;
- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width;

@end
