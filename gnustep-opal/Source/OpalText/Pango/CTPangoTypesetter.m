//
//  CTPangoTypesetter.m
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTPangoTypesetter.h"
#import "CTPangoLine.h"
// FIXME: use advanced layout engines if available
#import "OPSimpleLayoutEngine.h"

#import "PangoCoreGraphics-render.h"
#import "CTFont.h"
#import "CTStringAttributes.h"
#import "CTFoundationExtended.h"
#import "NSAttributedString+Pango.h"

@implementation CTPangoTypesetter
- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options
{
    self = [super initWithAttributedString:string options:options];
    if (self)
    {
        //      NSLog(@"Create typesetter with attributed string:%@, length:%d",string,string.length);
        PangoFontMap *fontmap = pango_cairo_font_map_new();
        
        PangoContext *pangoctx = pango_font_map_create_context(fontmap);
        _layout = pango_layout_new(pangoctx);
        
        pango_layout_set_attributedString_with_options(_layout, string, options);
        
        g_object_unref(fontmap);
        g_object_unref(pangoctx);
    }
    return self;
}

- (void) dealloc
{
    g_object_unref(_layout);
    [super dealloc];
}

- (CTLineRef)createLineWithRange: (CFRange)range offset:(CGFloat)offset
{
    
    CTPangoLine *l = [[CTPangoLine alloc] init];
    l.range = range;
    l.offset = offset;
    l.attributedString = _as;
    return (CTLineRef)l;
}

//FIXME: this implemente is wrong
//       pango cluster iter doesn't means 'cluster-break'
- (CFIndex)suggestClusterBreakAtIndex: (CFIndex)start
                                width: (double)width
{
    NSLog(@"%s unimplemented: idx:%d,%.2f",__PRETTY_FUNCTION__,start,width);
    pango_layout_set_width(_layout, width*PANGO_SCALE);
    
    PangoLayoutIter *iter = pango_layout_get_iter(_layout);
    int clusterIdx = 0;
    while (clusterIdx <= start) {
        bool su = pango_layout_iter_next_cluster(iter);
        clusterIdx = pango_layout_iter_get_index(iter);
        
        if (!su) {
            clusterIdx = _as.string.length;
            break;
        }
    }
    
    pango_layout_iter_free(iter);
    NSLog(@"suggest at idx: %d",clusterIdx);
    CFIndex textCount = clusterIdx - start;
    NSLog(@"suggest textcount:%d",textCount);
    return textCount;
}

- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width
{
    NSLog(@"%s unimplemented: idx:%d,%.2f",__PRETTY_FUNCTION__,start,width);
    
    PangoFontMap *fontmap = pango_cairo_font_map_get_default();
    PangoContext *pangoctx = pango_font_map_create_context(fontmap);
    PangoLayout *layout = pango_layout_new(pangoctx);
    
    NSAttributedString *as = [_as attributedSubstringFromRange:NSMakeRange(start, _as.length-start)];
    pango_layout_set_attributedString_with_options(layout, as, nil);
    pango_layout_set_width(layout, width*PANGO_SCALE);
    
    //
    // Algorithm:
    //  find the first line of pango layout, and count number of glyphs contains
    //
    // note:
    //  We don't use length of line, becuse it's UTF8 bytes length, convert it to UTF16 is a bit panic
    //
    
    PangoLayoutLine *firstLine = pango_layout_get_line_readonly(layout, 0);
    gint bytesLength = firstLine->length;
    
    gint glyphsCount = 0;
    
    // FIXME: Why sometimes first line is 0 length?
    // find first none-zero length line, let it as first line
    if (bytesLength == 0) {
        int lineCount = pango_layout_get_line_count(layout);
        for (int lineIdx = 1; lineIdx<lineCount; lineIdx++) {
            firstLine = pango_layout_get_line_readonly(layout, lineIdx);
            bytesLength = firstLine->length;
            
            //HACK
            // second line begin with a empty-attribute white-space,
            // pango layout it as a 0 length line
            // we cout it as one glyphs
            //FIXME: when start > 0, is the 'empty-attribute white-space' in the beginning of subattributedstring expected?
            glyphsCount ++;
            
            if (bytesLength > 0) {
                break;
            }
        }
    }
    
    // count number of glyphs in every run in line
    GSList *l;
    for (l = firstLine->runs; l; l=l->next) {
        PangoLayoutRun *run = l->data;
        PangoGlyphString *glyphs = run->glyphs;
        glyphsCount += glyphs->num_glyphs;
    }
    
    g_object_unref(layout);
    g_object_unref(pangoctx);
    
    //FIXME: workaround here
    // why out of range?
    if (glyphsCount >= as.length) {
//        NSLog(@"glyphs out of range(value:%d max:%d, fix it..",glyphsCount,as.length);
        glyphsCount = as.length - 1;
    }
    
    NSAssert((start + glyphsCount) < _as.length, @"suggested glyphs count out of range");
    return glyphsCount;
}

- (void)logLineAtIndex:(int)idx layout:(PangoLayout *)layout
{
    PangoLayoutLine *line = pango_layout_get_line(layout, idx);
    GList *l;
    gint glyphsCount = 0;
    for (l = line->runs; l; l=l->next) {
        PangoLayoutRun *run = l->data;
        PangoGlyphString *glyphs = run->glyphs;
        glyphsCount += glyphs->num_glyphs;
    }
    
    NSLog(@"lineIdx:%d length:%d glyphsCount:%d",idx,line->length,glyphsCount);
    
}

@end
