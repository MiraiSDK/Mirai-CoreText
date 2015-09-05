//
//  CTPangoFrame.m
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTPangoFrame.h"
#include <ft2build.h>
#include FT_FREETYPE_H
//#include <ftadvanc.h>
//#include <ftsnames.h>
//#include <tttables.h>

#include <harfbuzz/hb.h>
#include <harfbuzz/hb-ft.h>
#if ANDROID
#include <harfbuzz/hb-icu.h>
#else
#include <harfbuzz/hb-glib.h>
#endif

#include "PangoCoreGraphics-render.h"


@implementation CTPangoFrame
- (void)dealloc
{
    if (_layout) {
        g_object_unref(_layout);
    }
    [super dealloc];
}

- (void)setPangoLayout:(PangoLayout *)layout
{
    _layout = layout;
}

- (void) addLine: (CTLineRef)aLine
{
    [_lines addObject: aLine];
}

- (CGPathRef)path
{
    return NULL;
}

- (NSArray*)lines
{
    return nil;
}

- (NSRange)stringRange
{
    return _stringRange;
}

- (NSRange)visibleStringRange
{
    return _visibleStringRange;
}

- (void)setVisibleStringRange: (NSRange)aRange
{
    _visibleStringRange = aRange;
}

- (NSDictionary*)attributes
{
    return nil;
}

- (void)drawOnContext: (CGContextRef)ctx
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    CGContextSaveGState(ctx);
    
    CGRect rect;
    CGPathIsRect(_path, &rect);
    pango_coregraphics_show_layout_in_rect(ctx, _layout,rect);
    CGContextRestoreGState(ctx);
}
@end
