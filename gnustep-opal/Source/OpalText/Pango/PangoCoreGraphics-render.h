//
//  PangoCoreGraphics-render.h
//  CoreText
//
//  Created by Chen Yonghui on 12/30/13.
//  Copyright (c) 2013 Shanghai TinyNetwork Inc. All rights reserved.
//

#ifndef CoreText_PangoCoreGraphics_render_h
#define CoreText_PangoCoreGraphics_render_h

#import <CoreGraphics/CoreGraphics.h>
#include <pango/pango.h>


//Font Map

typedef struct _PangoCoreGraphicsFontMap        PangoCoreGraphicsFontMap;
#define PANGO_TYPE_COREGRAPHICS_FONT_MAP       (pango_coregraphics_font_map_get_type ())
GType pango_coregraphics_font_map_get_type (void) G_GNUC_CONST;

#define PANGO_TYPE_COREGRAPHICS_FONT            (pango_coregraphics_font_get_type ())
GType pango_coregraphics_font_get_type (void) G_GNUC_CONST;

PangoFontMap *
pango_coregraphics_font_map_new (void);

/*
 * Rendering
 */
void pango_coregraphics_show_layout_in_rect(CGContextRef ctx, PangoLayout *layout, CGRect rect);

void pango_coregraphics_show_layout_line(CGContextRef ctx, PangoLayoutLine *line);
void pango_coregraphics_show_glyph_item(CGContextRef ctx, const char *text, PangoGlyphItem *glyph_item);
void pango_coregraphics_show_glyph_string(CGContextRef ctx, PangoFont *font, PangoGlyphString *glyphs);
void pango_coregraphics_show_error_underline(CGContextRef ctx, CGRect rect);

/*
 * Rendering to a path
 */
void pango_coregraphics_glyph_string_path(CGContextRef ctx, PangoFont *font, PangoGlyphString *glyphs);
void pango_coregraphics_layout_line_path(CGContextRef ctx, PangoLayoutLine *line);
void pango_coregraphics_layout_path(CGContextRef ctx, PangoLayout *layout);
void pango_coregraphics_error_underline_path(CGContextRef ctx, CGRect rect);

#endif
