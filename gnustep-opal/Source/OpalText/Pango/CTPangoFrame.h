//
//  CTPangoFrame.h
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTFrame-private.h"
#include <pango/pango-layout.h>

@interface CTPangoFrame : CTFrame
{
    PangoLayout *_layout;
}

- (void)setPangoLayout:(PangoLayout *)layout;

@end
