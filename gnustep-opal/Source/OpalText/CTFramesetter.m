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
#import "CTFrame-private.h"

#import "CTStringAttributes.h"
#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>

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

- (PangoAttribute *)createPangoFontAttributeFromNSAttributedValue:(id)obj
{
    if ([obj isKindOfClass:NSClassFromString(@"NSFont")]) {
        
    } else if ([obj isKindOfClass:NSClassFromString(@"UIFont")]) {
        
    } else {
    }
//    CFStringRef f = CGFontCopyPostScriptName(obj);
    PangoFontDescription *desc = pango_font_description_new();
    pango_font_description_set_family(desc, "Arial");
//    pango_font_description_set_size(desc, 12);
    pango_font_description_set_absolute_size(desc, 12*PANGO_SCALE);
    pango_font_description_set_style(desc, PANGO_STYLE_NORMAL);
    PangoAttribute *attr =pango_attr_font_desc_new(desc);
    return attr;
}

- (PangoAttribute *)createPangoForegroundColorAttributeFromNSAttributedValue:(id)obj
{
    CGFloat *components = CGColorGetComponents(obj);
    PangoAttribute *attr = pango_attr_foreground_new(components[0] * 65535.,
                                                     components[1] * 65535.,
                                                     components[2] * 65535.);
    return attr;
}

- (PangoAttrList *)createAttrListFromAttributedString:(NSAttributedString *)attrStr
{
    PangoAttrList *list = pango_attr_list_new();
    [attrStr enumerateAttributesInRange:NSMakeRange(0, attrStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        [attrs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            PangoAttribute *patt = NULL;
            if ([key isEqualToString:(NSString *)kCTFontAttributeName]) {
                patt = [self createPangoFontAttributeFromNSAttributedValue:obj];
            } else if ([key isEqualToString:(NSString *)kCTForegroundColorAttributeName]) {
                patt = [self createPangoForegroundColorAttributeFromNSAttributedValue:obj];
            }
            
            if (patt != NULL) {
                patt->start_index = range.location;
                patt->end_index = NSMaxRange(range);
                pango_attr_list_insert(list, patt);
                g_object_unref(patt);
            }
        }];
    }];
    
    return list;
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
    NSString *frameString = [[_string string] substringWithRange:r];
    uint16_t length = frameString.length;
    pango_layout_set_text(layout, [frameString UTF8String], length);
    PangoAttrList *list = [self createAttrListFromAttributedString:_string];
    pango_layout_set_attributes(layout,list);
    pango_layout_set_width(layout, frameRect.size.width);
    pango_layout_set_height(layout, frameRect.size.height);
    PangoFontDescription *desc = pango_font_description_from_string("Helvetica Regular 12");
    pango_layout_set_font_description(layout,desc);

    pango_font_description_free(desc);
    pango_attr_list_unref(list);
    
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
  // FIXME: Implement.
  // This calculates whether (/ how much of) an attributed string fits in a
  // given rect. This will have to pretty much do a full typesetting
  // like for CTFramesetterCreateFrame
  return CGSizeMake(0,0);
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
