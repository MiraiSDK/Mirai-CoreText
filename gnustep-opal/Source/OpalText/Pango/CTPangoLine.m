//
//  CTPangoLine.m
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTPangoLine.h"

//#include <pango/pango.h>
#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>
#import "NSAttributedString+Pango.h"
#import "CTPangoRun.h"

@implementation CTPangoLine {
    PangoLayout *_layout;
}

- (void)dealloc
{
    [_attributedString release];
    if (_layout) {
        g_object_unref(_layout);
    }
    [super dealloc];
}

- (void)generatePangoObjects
{
    @synchronized(self) {
        if (_layout == NULL) {
            NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];

            PangoFontMap *fm = pango_cairo_font_map_get_default();
            PangoContext *pangoCtx = pango_font_map_create_context(fm);
            PangoLayout *layout = pango_layout_new(pangoCtx);
            pango_layout_set_attributedString(layout, lineAS);
            pango_layout_set_single_paragraph_mode(layout, true);

            _layout = layout;
            g_object_unref(pangoCtx);
        }
    }
}

- (CFRange)stringRange
{
    return self.range;
}

- (void)drawOnContext: (CGContextRef)ctx
{
    if (self.attributedString) {
        CGContextSaveGState(ctx);
        
        NSLog(@"str:%@ length:%d",self.attributedString.string,self.attributedString.length);
        NSLog(@"lineRange:{%d,%d}",self.range.location,self.range.length);
        NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
        
        // prepare pango
        PangoFontMap *fm = pango_cairo_font_map_get_default();
        PangoContext *pangoCtx = pango_font_map_create_context(fm);
        PangoLayout *layout = pango_layout_new(pangoCtx);
        pango_layout_set_attributedString(layout, lineAS);
        pango_layout_set_single_paragraph_mode(layout, true);
        
        // calculate line rect
        CGPoint textPosition = CGContextGetTextPosition(ctx);
        int width,height;
        pango_layout_get_pixel_size(layout, &width, &height);
        CGRect rect = CGRectMake(textPosition.x, textPosition.y, width, height);
        
        NSLog(@"draw line at rect:{{%.2f,%.2f},{%.2f,%.2f}} str:%@",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height,lineAS.string);
        
        pango_coregraphics_show_layout_in_rect(ctx, layout, rect);
        
        g_object_unref(layout);
        g_object_unref(pangoCtx);
        
        CGContextRestoreGState(ctx);
    } else {
        const NSUInteger runsCount = [_runs count];
        for (NSUInteger i=0; i<runsCount; i++)
        {
            CTRunRef run = [_runs objectAtIndex: i];
            CTRunDraw(run, ctx, CFRangeMake(0, 0));
        }
    }
}

- (CGFloat)width
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);
    
    int width,height;
    pango_layout_get_pixel_size(layout, &width, &height);
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    
    return width;
}

- (CGFloat) offsetForIndex:(CFIndex) charIndex
           secondaryOffset:(CGFloat*) secondaryOffset
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);
    
    PangoRectangle rect;
    
    NSString * str = [lineAS string];
    signed long charIndexInLine = charIndex - self.range.location;
    if (charIndexInLine < 0) {
        charIndexInLine = 0;
    }
    charIndexInLine = [str UTF8IndexForIndex:charIndexInLine];
    
    pango_layout_index_to_pos(layout, (int)charIndexInLine, &rect);
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    CGFloat offset = rect.x / PANGO_SCALE;
    if (secondaryOffset) {
        *secondaryOffset = offset;
    }
    return offset;
}

- (CFIndex)stringIndexForPosition:(CGPoint)point
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    NSString *lineStr = lineAS.string;
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);
    
    int x = point.x * PANGO_SCALE;
    int y = point.y * PANGO_SCALE;
    int index,trailing;
    pango_layout_xy_to_index(layout,x,y,&index,&trailing);
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    
    CFIndex UTF16Index = (CFIndex)[lineStr indexForUTF8Index:index];
    return self.range.location + UTF16Index;
}

- (double)getTypographicBoundsAscent:(CGFloat *)ascent descent:(CGFloat *)descent leading:(CGFloat *)leading
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);
    
    int width,height;
    pango_layout_get_pixel_size(layout,&width,&height);
    
    if (ascent) {
        *ascent = height;
    }
    if (descent) {
        *descent = 0;
    }
    
    if (leading) {
        *leading = 0;
    }
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    
    return width;
}

- (NSArray*)glyphRuns
{
    [self generatePangoObjects];
    
    NSMutableArray *runs = [NSMutableArray array];
    
    PangoLayoutIter *iter = pango_layout_get_iter(_layout);
    CFIndex location = 0;
    do {
        PangoLayoutRun *pangoRun = pango_layout_iter_get_run_readonly(iter);

        if (pangoRun == NULL) { //every pango line end with a NULL run
            continue;
        }
        
        PangoRectangle logical_rect;
        pango_layout_iter_get_run_extents(iter, NULL, &logical_rect);

        PangoGlyphString *glyphStr = pangoRun->glyphs;
        
        pango_layout_iter_get_index(iter);
        CTPangoRun *run = [[CTPangoRun alloc] initWithRun:pangoRun];
        run.line = self;
        run.logical_rect = logical_rect;
        run.layout = _layout;
        run.stringRange = CFRangeMake(location, glyphStr->num_glyphs);
        location += glyphStr->num_glyphs;
        
        [runs addObject:run];

        
    } while (pango_layout_iter_next_run(iter));
    pango_layout_iter_free(iter);
    
    return runs;
}

@end
