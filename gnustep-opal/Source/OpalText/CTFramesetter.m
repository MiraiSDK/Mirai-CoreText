/** <title>CTFramesetter</title>

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

#include <CoreText/CTFramesetter.h>
#include <CoreText/CTRunDelegate.h>
#import "CTFrame-private.h"

#import "CTStringAttributes.h"
#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>

#import "CTFoundationExtended.h"
#import "CTFont.h"
#import "NSAttributedString+Pango.h"

/* Classes */

/**
 * Convenience class which typsets a whole paragraph.
 * I believe this can be totally implemented using the public API of CTTypesetter
 */
@interface CTFramesetter : NSObject
{
  NSAttributedString *_string;
  CTTypesetterRef _ts;
}

- (id)initWithAttributedString: (NSAttributedString*)string;

- (CTFrameRef)createFrameWithRange: (CFRange)range
                              path: (CGPathRef)path
                        attributes: (NSDictionary*)attributes;
- (CTTypesetterRef)typesetter;
- (CGSize)suggestFrameSizeWithRange: (CFRange)stringRange
                          attributes: (CFDictionaryRef)attributes
                         constraints: (CGSize)constraints
                            fitRange: (CFRange*)fitRange;

@end

@implementation CTFramesetter

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

- (id)initWithAttributedString: (NSAttributedString*)string
{
  self = [super init];
  if (nil == self)
  {
    return nil;
  }

  _string = [string retain];
  _ts = CTTypesetterCreateWithAttributedString(string);

  return self;
}

- (void)dealloc
{
  [_string release];
  [_ts release];
  [super dealloc];
}

- (CTFrameRef)createFrameWithRange: (CFRange)range
                              path: (CGPathRef)path
                        attributes: (NSDictionary*)attributes
{
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
    
    
  CTFrame *frame = [[CTFrame alloc] initWithPath: path
                                       stringRange: r
                                        attributes: attributes];
    
    PangoFontMap *fontmap = pango_cairo_font_map_new();
    PangoContext *pangoctx = pango_font_map_create_context(fontmap);
    PangoLayout *layout = pango_layout_new(pangoctx);
    
    pango_layout_set_attributedString_with_options(layout, _string, nil);
    
    pango_layout_set_width(layout, PANGO_SCALE * frameRect.size.width);
    pango_layout_set_height(layout, PANGO_SCALE * frameRect.size.height);

    
    [frame setPangoLayout:layout];
    
    // set visible range
    
    // FIXME: take in to account CTTextTab settings (alignment, justification, etc?)

//  switch ([[attributes objectForKey: kCTFrameProgressionAttributeName] intValue])
//  {
//    default:
//    case kCTFrameProgressionTopToBottom:
//    {
//      CFIndex start = 0;
//      while (start < [_string length])
//      {
//        CFIndex lineBreak = CTTypesetterSuggestLineBreak(_ts, start, frameRect.size.width);
//
//        CTLineRef line = CTTypesetterCreateLine(_ts, CFRangeMake(start, lineBreak));
//        [frame addLine: line];
//        [line release];
//        
//        if (start == lineBreak)
//          {
//            NSLog(@"WARNING: Broke possible infinite loop in %s; string %@", __PRETTY_FUNCTION__, _string);
//            break;
//          }
//        start = lineBreak;
//      }
//      break;
//    }
//    case kCTFrameProgressionRightToLeft:
//      // FIXME: as above but for right to left, vertical text layout
//      break;
//  }

  return frame;
}

- (CTTypesetterRef)typesetter
{
  return _ts;
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


/* Functions */

CTFramesetterRef CTFramesetterCreateWithAttributedString(CFAttributedStringRef string)
{
  return [[CTFramesetter alloc] initWithAttributedString: string];
}

CTFrameRef CTFramesetterCreateFrame(
	CTFramesetterRef framesetter,
	CFRange stringRange,
	CGPathRef path,
	CFDictionaryRef attributes)
{
  return [framesetter createFrameWithRange: stringRange
                                      path: path
                                attributes: attributes];
}

CTTypesetterRef CTFramesetterGetTypesetter(CTFramesetterRef framesetter)
{
  return [framesetter typesetter];
}

CGSize CTFramesetterSuggestFrameSizeWithConstraints(
	CTFramesetterRef framesetter,
	CFRange stringRange,
	CFDictionaryRef attributes,
	CGSize constraints,
	CFRange* fitRange)
{
  return [framesetter suggestFrameSizeWithRange: stringRange
                                     attributes: attributes
                                    constraints: constraints
                                       fitRange: fitRange];
}

CFTypeID CTFramesetterGetTypeID()
{
  return (CFTypeID)[CTFramesetter class];
}
