//
//  CTPangoRun.m
//  CoreText
//
//  Created by Chen Yonghui on 9/8/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTPangoRun.h"
#import <pango/pangocairo.h>

@implementation CTPangoRun

- (instancetype)initWithRun:(PangoLayoutRun *)run
{
    self = [super init];
    if (self) {
        _pangoRun = run;
        
        PangoGlyphString *glyphs = run->glyphs;
        _count = glyphs->num_glyphs;
        _glyphs = malloc(sizeof(CGGlyph) * glyphs->num_glyphs);
        _positions = malloc(sizeof(CGPoint) * glyphs->num_glyphs);
        
        CGFloat x = 0;
        CGFloat y = 0;
        for (int i = 0; i< glyphs->num_glyphs; i++) {
            PangoGlyphInfo *glyphInfo = &glyphs->glyphs[i];
            _glyphs[i] = glyphInfo->glyph;
            CGPoint p = CGPointMake( x + PANGO_PIXELS(glyphInfo->geometry.x_offset),
                                    y + PANGO_PIXELS(glyphInfo->geometry.y_offset));
            _positions[i] = p;
            
            CGFloat width = PANGO_PIXELS(glyphInfo->geometry.width);

            x+= width;
            NSLog(@"glyph: position:%.2f,%.2f",p.x,p.y);
        }
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (CFRange)stringRange
{
    return [super stringRange];
}

- (void)setStringRange:(CFRange)stringRange
{
    _stringRange = stringRange;
}

- (double)typographicBoundsForRange: (CFRange)range
                             ascent: (CGFloat*)ascent
                            descent: (CGFloat*)descent
                            leading: (CGFloat*)leading
{
    if (ascent) {
        *ascent = self.logical_rect.height;
    }
    
    if (descent) {
        *descent = 0;
    }
    
    if (leading) {
        *leading = 0;
    }
    
    return self.logical_rect.width;
}

- (void)drawRange: (CFRange)range onContext: (CGContextRef)ctx
{
    if (range.length == 0)
    {
        range.length = _count;
    }
    
    if (range.location > _count || (range.location + range.length) > _count)
    {
        NSLog(@"CTRunDraw range out of bounds");
        return;
    }
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0,0,0,1};
    CGColorRef c = CGColorCreate(cs, components);
    CGContextSetFillColorWithColor(ctx, c);
    
    const PangoFontDescription *fontDescription = pango_layout_get_font_description(_layout);
    const char * fontFamily = pango_font_description_get_family(fontDescription);
    CFStringRef familyRef = CFStringCreateWithCString(kCFAllocatorDefault, fontFamily, kCFStringEncodingUTF8);
    CGFontRef f = CGFontCreateWithFontName(familyRef);
    CGContextSetFont(ctx, f);
    CGFontRelease(f);
    CFRelease(familyRef);

    gint fontSize = pango_font_description_get_size(fontDescription);
    CGFloat cg_fontSize = fontSize/PANGO_SCALE;
    if (cg_fontSize == 0) {
        NSLog(@"[ERROR] fontSize is 0, fix it to 12");
        cg_fontSize = 12;
    }
    NSLog(@"set fontSize to %.2f",cg_fontSize);
    CGContextSetFontSize(ctx, cg_fontSize);

    CGContextSaveGState(ctx);
    CGContextShowGlyphs(ctx, _glyphs, _count);
    CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(cs);
    CGColorRelease(c);
}
@end
