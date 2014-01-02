/** <title>CTFrame</title>

   <abstract>C Interface to text layout library</abstract>

   Copyright <copy>(C) 2010 Free Software Foundation, Inc.</copy>

   Author: Eric Wasylishen
   Date: Aug 2010

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
   */

#include <CoreText/CTFrame.h>
#import "CTFrame-private.h"

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

#include <pango/pangocairo.h>
#include "PangoCoreGraphics-render.h"


/* Constants */

const CFStringRef kCTFrameProgressionAttributeName = @"kCTFrameProgressionAttributeName";

/* Classes */

@implementation CTFrame

- (id) initWithPath: (CGPathRef)aPath
        stringRange: (NSRange)aRange
         attributes: (NSDictionary*)attribs
{
  if ((self = [super init]))
  {
    _path = [aPath retain];
    _lines = [[NSMutableArray alloc] init];
    _attributes = [attribs copy];
    _stringRange = aRange;
  }
  return self;
}

- (void) dealloc
{
  [_attributes release];
  [_path release];
  [_lines release];
  [super dealloc];
}

- (void) addLine: (CTLineRef)aLine
{
  [_lines addObject: aLine];
}

- (CGPathRef)path
{
  return _path;
}

- (NSArray*)lines
{
  return _lines;
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
  // FIXME: see CTFrameProgression docs comment about rotating 90 degrees
  NSUInteger linesCount = [_lines count];
  for (NSUInteger i=0; i<linesCount; i++)
  {
    CTLineRef line = [_lines objectAtIndex: i];
    // FIXME: How does positioning work?
    CTLineDraw(line, ctx);
  }
}

@end

/* Functions */

CFRange CTFrameGetStringRange(CTFrameRef frame)
{
  NSRange range = [frame stringRange];
  return CFRangeMake(range.location, range.length);
}

CFRange CTFrameGetVisibleStringRange(CTFrameRef frame)
{
  NSRange range = [frame visibleStringRange];
  return CFRangeMake(range.location, range.length);
}

CGPathRef CTFrameGetPath(CTFrameRef frame)
{
  return [frame path];
}

CFDictionaryRef CTFrameGetFrameAttributes(CTFrameRef frame)
{
  return [frame attributes];
}

CFArrayRef CTFrameGetLines(CTFrameRef frame)
{
  return [frame lines];
}

void CTFrameGetLineOrigins(
	CTFrameRef frame,
	CFRange range,
	CGPoint origins[])
{
}

void CTFrameDraw(CTFrameRef frame, CGContextRef ctx)
{
//    CGContextSaveGState(ctx);
    CGColorRef color = CGColorCreateGenericRGB(1, 0, 0, 1);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextSelectFont(ctx, "Arial", 14, kCGEncodingMacRoman);
//    CGContextShowTextAtPoint(ctx, 0, 0, "hello world", 10);
//    CGContextRestoreGState(ctx);
    
    /*
    FT_Library ft_library;
    FT_Init_FreeType(&ft_library);
    
    FT_Face ft_face;
    double ptSize = 50.0;
    int device_hdpi = 100;
    int device_vdpi = 100;
    FT_New_Face(ft_library, "/Library/Fonts/Arial.ttf", 0, &ft_face);
    FT_Set_Char_Size(ft_face, 0, ptSize, device_hdpi, device_vdpi);
    
    hb_font_t *hb_ft_font;
    hb_face_t *hb_ft_face;
    
    hb_ft_font = hb_ft_font_create(ft_face, NULL);
    hb_ft_face = hb_ft_face_create(ft_face, NULL);
    
    hb_buffer_t *buf = hb_buffer_create();
    
#if ANDROID
    hb_buffer_set_unicode_funcs(buf, hb_icu_get_unicode_funcs());
#else
//    hb_buffer_set_unicode_funcs(buf, hb_glib_get_unicode_funcs());
#endif

    hb_buffer_set_direction(buf, HB_DIRECTION_LTR);
    hb_buffer_set_script(buf, HB_SCRIPT_LATIN);
    hb_buffer_set_language(buf, hb_language_from_string("en", strlen("en")));
    
    NSString *str = @"Hello Miku";
    hb_buffer_add_utf8(buf, str.UTF8String, str.length, 0, str.length);
    hb_shape(hb_ft_font, buf, NULL, 0);
    
    unsigned int glyph_count;
    hb_glyph_info_t *glyph_info = hb_buffer_get_glyph_infos(buf, &glyph_count);
    hb_glyph_position_t *glyph_pos = hb_buffer_get_glyph_positions(buf, &glyph_count);
    CGGlyph *cg_glyphs = malloc(sizeof(CGGlyph) * glyph_count);
    CGPoint *cg_positions = malloc(sizeof(CGPoint) * glyph_count);
    
    CGFloat x = 0;
    CGFloat y = 0;
    for (int i = 0; i<glyph_count; ++i) {
        hb_glyph_info_t info = glyph_info[i];
        cg_glyphs[i] = info.codepoint;
        
        hb_glyph_position_t hb_position = glyph_pos[i];
        CGPoint p = CGPointMake(x + hb_position.x_offset,
                                y + hb_position.y_offset);
        cg_positions[i] = p;
        
        x += hb_position.x_advance;
        y += hb_position.y_advance;
    }
    
    CGContextShowGlyphsAtPositions(ctx, cg_glyphs, cg_positions, glyph_count);
    
    free(cg_glyphs);
    free(cg_positions);
     */
//    g_type_init();
    PangoFontMap *fontmap = pango_cairo_font_map_new();
    PangoContext *pangoctx = pango_font_map_create_context(fontmap);
    PangoLayout *layout = pango_layout_new(pangoctx);
     ;
    pango_layout_set_text(layout,"Hello Miku\nHatsune",-1);
    PangoFontDescription *desc = pango_font_description_from_string("Sans Bold 27");
    pango_layout_set_font_description(layout,desc);
    pango_font_description_free(desc);
    
    CGContextSaveGState(ctx);
    pango_coregraphics_show_layout(ctx, layout);
    CGContextRestoreGState(ctx);
    
//  [frame drawOnContext: ctx];
}

CFTypeID CTFrameGetTypeID()
{
  return (CFTypeID)[CTFrame class];
}

