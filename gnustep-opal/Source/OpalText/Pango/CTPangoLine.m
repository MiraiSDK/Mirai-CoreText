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

@implementation CTPangoLine
- (void)dealloc
{
    [_attributedString release];
    [super dealloc];
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
        CGRect rect = CGRectMake(textPosition.x, textPosition.y - height, width, height);
        
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

@end
