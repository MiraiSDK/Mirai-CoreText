//
//  PangoCoreGraphics-render.c
//  CoreText
//
//  Created by Chen Yonghui on 12/30/13.
//  Copyright (c) 2013 Shanghai TinyNetwork Inc. All rights reserved.
//

#include <stdio.h>
#include "PangoCoreGraphics-render.h"


//Font Map

#define PANGO_TYPE_COREGRAPHICS_FONT_MAP             (pango_coregraphics_font_map_get_type ())
GType                 pango_coregraphics_font_map_get_type          (void) G_GNUC_CONST;

typedef struct _PangoCoreGraphicsFontMapClass PangoCoreGraphicsFontMapClass;

struct _PangoCoreGraphicsFontMapClass
{
//     *parent_class;
};

static void
pango_coregraphics_font_map_class_init (PangoCoreGraphicsFontMapClass *class)
{
    
}

static void
pango_coregraphics_font_map_init (PangoCoreGraphicsFontMap *fontmap)
{
    
}

//PangoFontMap *
//pango_coregraphics_font_map_new (void)
//{
#if !GLIB_CHECK_VERSION (2, 35, 3)
//    g_type_init ();
#endif
//    return g_object_new(PANGO_TYPE_COREGRAPHICS_FONT_MAP, NULL);
    
//}

//Renderning

// private
#define PANGO_TYPE_COREGRAPHICS_RENDERER            (pango_coregraphics_renderer_get_type())

typedef struct _PangoCoreGraphicsRenderer PangoCoreGraphicsRenderer;
GType pango_coregraphics_renderer_get_type (void) G_GNUC_CONST;

//
typedef struct _PangoCoreGraphicsRendererClass PangoCoreGraphicsRendererClass;

struct _PangoCoreGraphicsRenderer
{
    PangoRenderer parent_instance;
    
    CGContextRef ctx;
    CGRect rect;
    gboolean is_cached_renderer;
    
};

struct _PangoCoreGraphicsRendererClass
{
    PangoRendererClass parent_class;
};

G_DEFINE_TYPE(PangoCoreGraphicsRenderer, pango_coregraphics_renderer, PANGO_TYPE_RENDERER);

static void
set_color (PangoCoreGraphicsRenderer *crenderer,
           PangoRenderPart     part)
{
    PangoColor *color = pango_renderer_get_color ((PangoRenderer *) (crenderer), part);
    
    if (color) {
        CGColorRef cg_color = CGColorCreateGenericRGB(color->red / 65535., color->green / 65535., color->blue / 65535., 1);
        CGContextSetFillColorWithColor(crenderer->ctx, cg_color);
        CGColorRelease(cg_color);
        
    }
}

static void
pango_coregraphics_renderer_show_text_glyphs (PangoRenderer        *renderer,
                                              const char           *text,
                                              int                   text_len,
                                              PangoGlyphString     *glyphs,
//                                              cairo_text_cluster_t *clusters,
//                                              int                   num_clusters,
                                              gboolean              backward,
                                              PangoFont            *font,
                                              int                   x,
                                              int                   y)

{
    PangoCoreGraphicsRenderer *crenderer = (PangoCoreGraphicsRenderer *) (renderer);
    CGContextRef ctx = crenderer->ctx;
    
    int i, count;
    
    CGFloat gx = 0;
    CGFloat gy = 0;
    
    double base_x = x / PANGO_SCALE;
    double base_y = y / PANGO_SCALE;
    
    
    gint num_glyphs = glyphs->num_glyphs;
    CGFloat height = crenderer->rect.size.height;
    
    CGGlyph *cg_glyphs = malloc(sizeof(CGGlyph) * glyphs->num_glyphs);
    CGPoint *cg_positions = malloc(sizeof(CGPoint) * glyphs->num_glyphs);
    
    CGContextSaveGState(ctx);
    set_color(crenderer, PANGO_RENDER_PART_FOREGROUND);

    
    for (i = 0; i< glyphs->num_glyphs; i++) {
        PangoGlyphInfo *glyphInfo = &glyphs->glyphs[i];
        cg_glyphs[i] = glyphInfo->glyph;
        
        CGPoint p = CGPointMake(base_x + gx + glyphInfo->geometry.x_offset,
                                base_y +gy);
        
        //flip coordination
        p.y = height - p.y;
        
        cg_positions[i] = p;
//        if (glyphInfo->glyph != PANGO_GLYPH_EMPTY) {
//        }
        gx += glyphInfo->geometry.width/PANGO_SCALE;
    }

    PangoFontDescription *fontDescription = pango_font_describe_with_absolute_size(font);
    const char * fontFamily = pango_font_description_get_family(fontDescription);
    CFStringRef familyRef = CFStringCreateWithCString(kCFAllocatorDefault, fontFamily, kCFStringEncodingUTF8);
    CGFontRef f = CGFontCreateWithFontName(familyRef);
    CGContextSetFont(ctx, f);
    CGFontRelease(f);
    CFRelease(familyRef);
    
    gint fontSize = pango_font_description_get_size(fontDescription);
    CGFloat cg_fontSize = fontSize/PANGO_SCALE;
    CGContextSetFontSize(ctx, cg_fontSize);
    
    CGContextShowGlyphsAtPositions(crenderer->ctx, cg_glyphs, cg_positions, glyphs->num_glyphs);
    free(cg_glyphs);
    free(cg_positions);
    CGContextRestoreGState(crenderer->ctx);
    
}
#pragma mark - Subclass
static void
pango_coregraphics_renderer_draw_glyphs (PangoRenderer       *renderer,
                                         PangoFont           *font,
                                         PangoGlyphString    *glyphs,
                                         int                 x,
                                         int                 y)
{
    printf("%s\n",__PRETTY_FUNCTION__);
    
//    gint num_glyphs = glyphs.num_glyphs;
//    PangoGlyphInfo gi = glyphs.glyphs[0];
//    uint s = gi.glyph;
    pango_coregraphics_renderer_show_text_glyphs(renderer,
                                                 NULL,0,
                                                 glyphs,
                                                 FALSE,
                                                 font,
                                                 x,y);

}

static void
pango_coregraphics_renderer_draw_glyphs_item (PangoRenderer     *renderer,
                                              const char        *text,
                                              PangoGlyphItem    *glyph_item,
                                              int               x,
                                              int               y)
{
    printf("%s\n",__PRETTY_FUNCTION__);

}

static void
pango_coregraphics_renderer_draw_rectangle (PangoRenderer     *renderer,
                                            PangoRenderPart    part,
                                            int                x,
                                            int                y,
                                            int                width,
                                            int                height)
{
    printf("%s\n",__PRETTY_FUNCTION__);
}

static void
pango_coregraphics_renderer_draw_trapezoid (PangoRenderer     *renderer,
                                            PangoRenderPart    part,
                                            double             y1_,
                                            double             x11,
                                            double             x21,
                                            double             y2,
                                            double             x12,
                                            double             x22)
{
    printf("%s\n",__PRETTY_FUNCTION__);

}
// instance init
static void
pango_coregraphics_renderer_init (PangoCoreGraphicsRenderer *renderer G_GNUC_UNUSED)
{
    printf("%s\n",__PRETTY_FUNCTION__);

}

static void
pango_coregraphics_renderer_draw_error_underline (PangoRenderer *renderer,
                                           int            x,
                                           int            y,
                                           int            width,
                                           int            height)
{
    printf("%s\n",__PRETTY_FUNCTION__);

}

static void
pango_coregraphics_renderer_draw_shape (PangoRenderer  *renderer,
                                 PangoAttrShape *attr,
                                 int             x,
                                 int             y)
{
    printf("%s\n",__PRETTY_FUNCTION__);

}

// class init
static void pango_coregraphics_renderer_class_init (PangoCoreGraphicsRendererClass *klass)
{
    PangoRendererClass *renderer_class = PANGO_RENDERER_CLASS(klass);
    
    renderer_class->draw_glyphs = pango_coregraphics_renderer_draw_glyphs;
    renderer_class->draw_glyph_item = pango_coregraphics_renderer_draw_glyphs_item;
    renderer_class->draw_rectangle = pango_coregraphics_renderer_draw_rectangle;
    renderer_class->draw_trapezoid = pango_coregraphics_renderer_draw_trapezoid;
    renderer_class->draw_error_underline = pango_coregraphics_renderer_draw_error_underline;
    renderer_class->draw_shape = pango_coregraphics_renderer_draw_shape;

}

#pragma mark - render instance
static PangoCoreGraphicsRenderer *cached_renderer = NULL;
G_LOCK_DEFINE_STATIC (cached_renderer);

static PangoCoreGraphicsRenderer *
acquire_renderer (void)
{
    PangoCoreGraphicsRenderer *renderer;
    
    if (G_LIKELY (G_TRYLOCK (cached_renderer)))
    {
        if (G_UNLIKELY (!cached_renderer))
        {
            cached_renderer = g_object_new (PANGO_TYPE_COREGRAPHICS_RENDERER, NULL);
            cached_renderer->is_cached_renderer = TRUE;
        }
        
        renderer = cached_renderer;
    }
    else
    {
        renderer = g_object_new (PANGO_TYPE_COREGRAPHICS_RENDERER, NULL);
    }
    
    return renderer;
}

static void
release_renderer (PangoCoreGraphicsRenderer *renderer)
{
    if (G_LIKELY (renderer->is_cached_renderer))
    {
//        renderer->cr = NULL;
//        renderer->do_path = FALSE;
//        renderer->has_show_text_glyphs = FALSE;
//        renderer->x_offset = 0.;
//        renderer->y_offset = 0.;
        
        G_UNLOCK (cached_renderer);
    }
    else
        g_object_unref (renderer);
}



#pragma mark - private

static void
_pango_coregraphics_do_layout (CGContextRef     ctx,
                               PangoLayout *layout,
                               CGRect rect,
                               gboolean     do_path)
{
    printf("%s\n",__PRETTY_FUNCTION__);

    PangoCoreGraphicsRenderer *crenderer = acquire_renderer();
    PangoRenderer *renderer = (PangoRenderer *) crenderer;
    crenderer->ctx = ctx;
    crenderer->rect = rect;

    pango_renderer_draw_layout(renderer, layout, 0, 0);
    
    release_renderer(crenderer);
}


#pragma mark - Public API
#pragma mark Rendering
void pango_coregraphics_show_layout_in_rect(CGContextRef ctx, PangoLayout *layout, CGRect rect)
{
    _pango_coregraphics_do_layout(ctx, layout, rect, FALSE);
}

void pango_coregraphics_show_layout_line(CGContextRef ctx, PangoLayoutLine *line)
{
    
}

void pango_coregraphics_show_glyph_item(CGContextRef ctx, const char *text, PangoGlyphItem *glyph_item)
{
    
}

void pango_coregraphics_show_glyph_string(CGContextRef ctx, PangoFont *font, PangoGlyphString *glyphs)
{
    
}

void pango_coregraphics_show_error_underline(CGContextRef ctx, CGRect rect)
{
    
}

#pragma mark Renderning to a path
void pango_coregraphics_glyph_string_path(CGContextRef ctx, PangoFont *font, PangoGlyphString *glyphs)
{
    
}

void pango_coregraphics_layout_line_path(CGContextRef ctx, PangoLayoutLine *line)
{
    
}

void pango_coregraphics_layout_path(CGContextRef ctx, PangoLayout *layout)
{
    
}

void pango_coregraphics_error_underline_path(CGContextRef ctx, CGRect rect)
{
    
}







