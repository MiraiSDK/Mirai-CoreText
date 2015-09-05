//
//  CTPangoFramesetter.m
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTPangoFramesetter.h"
#import "CTFrame-private.h"
#import "CTFramesetter-private.h"
#import "CTPangoFrame.h"

#import "CTStringAttributes.h"
#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>

#import "CTFoundationExtended.h"
#import "CTFont.h"
#import "NSAttributedString+Pango.h"

@implementation CTPangoFramesetter
static void glib_NSLog_print_handler(const gchar *string)
{
    NSLog(@"%s",string);
}

NSString *descriptionForGLogLevel(GLogLevelFlags log_level)
{
    GLogLevelFlags level = log_level & G_LOG_LEVEL_MASK;
    NSString *levelStr = nil;
    switch (level) {
        case G_LOG_LEVEL_ERROR:levelStr = @"ERROR";break;
        case G_LOG_LEVEL_CRITICAL:levelStr = @"CRITICAL";break;
        case G_LOG_LEVEL_WARNING:levelStr = @"WARNING";break;
        case G_LOG_LEVEL_MESSAGE:levelStr = @"MESSAGE";break;
        case G_LOG_LEVEL_INFO:levelStr = @"INFO";break;
        case G_LOG_LEVEL_DEBUG:levelStr = @"DEBUG";break;
            
        default:levelStr = @"UNKNOW";break;
    }
    
    return levelStr;
}

static void glib_log_handler_NSLog(const gchar *log_domain, GLogLevelFlags log_level, const gchar *message, gpointer unused_data)
{
    NSLog(@"[%s][%@]%s",log_domain,descriptionForGLogLevel(log_level), message);
}

+(void)load
{
    g_log_set_default_handler(&glib_log_handler_NSLog, NULL);
}

#pragma mark - 

- (CTFrameRef)createFrameWithRange: (CFRange)range
                              path: (CGPathRef)path
                        attributes: (NSDictionary*)attributes
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    CGRect frameRect;
    if (!CGPathIsRect(path, &frameRect))
    {
        return nil;
    }
    
    if (!_string)
    {
        return nil;
    }
    
    NSRange r = NSMakeRange(range.location, range.length);
    if (r.location == 0 && r.length == 0) {
        r.length = _string.length;
    }
    
    
    CTFrame *frame = [[CTPangoFrame alloc] initWithPath: path
                                                 stringRange: r
                                                  attributes: attributes];
    
    PangoFontMap *fontmap = pango_cairo_font_map_new();
    PangoContext *pangoctx = pango_font_map_create_context(fontmap);
    PangoLayout *layout = pango_layout_new(pangoctx);
    
    pango_layout_set_attributedString_with_options(layout, _string, nil);
    
    pango_layout_set_width(layout, PANGO_SCALE * frameRect.size.width);
    pango_layout_set_height(layout, PANGO_SCALE * frameRect.size.height);
    
    
    [frame setPangoLayout:layout];

    
    return frame;
}

- (CGSize)suggestFrameSizeWithRange: (CFRange)stringRange
                         attributes: (CFDictionaryRef)attributes
                        constraints: (CGSize)constraints
                           fitRange: (CFRange*)fitRange
{
    // FIXME: correct string attributes
    PangoFontMap *fontmap = pango_cairo_font_map_new();
    PangoContext *pangoctx = pango_font_map_create_context(fontmap);
    PangoLayout *layout = pango_layout_new(pangoctx);
    
    pango_layout_set_width(layout, PANGO_SCALE * constraints.width);
    pango_layout_set_height(layout, PANGO_SCALE *constraints.height);
    
    NSAttributedString *as = _string;
    if (stringRange.length > 0) {
        NSRange makeRange = NSMakeRange(stringRange.location, stringRange.length);
        as = [_string attributedSubstringFromRange:makeRange];
    }
    pango_layout_set_attributedString_with_options(layout, as, nil);
    
    int width,height;
    pango_layout_get_pixel_size(layout, &width, &height);
    CGSize suggestSize = CGSizeMake(width, height);
    return suggestSize;
}
@end
