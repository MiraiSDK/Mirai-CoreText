/** <title>CTTypesetter</title>

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

#include <CoreText/CTTypesetter.h>
#include <CoreText/CTRunDelegate.h>

#import "CTLine-private.h"
// FIXME: use advanced layout engines if available
#import "OPSimpleLayoutEngine.h"

#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>
#import "CTFont.h"
#import "CTStringAttributes.h"
#import "CTFoundationExtended.h"
#import "NSAttributedString+Pango.h"

/* Constants */

const CFStringRef kCTTypesetterOptionDisableBidiProcessing = @"kCTTypesetterOptionDisableBidiProcessing";
const CFStringRef kCTTypesetterOptionForcedEmbeddingLevel = @"kCTTypesetterOptionForcedEmbeddingLevel";

/* Classes */

/**
 * Typesetter
 */
@interface CTTypesetter : NSObject
{
  NSAttributedString *_as;
  NSDictionary *_options;
    
    PangoLayout *_layout;
}

- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options;

- (CTLineRef)createLineWithRange: (CFRange)range;
- (CFIndex)suggestClusterBreakAtIndex: (CFIndex)start
                                width: (double)width;
- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width;

@end

@implementation CTTypesetter

- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options
{
  if ((self = [super init]))
  {
      NSLog(@"Create typesetter with attributed string:%@, length:%d",string,string.length);
      PangoFontMap *fontmap = pango_cairo_font_map_new();
      PangoContext *pangoctx = pango_font_map_create_context(fontmap);
      _layout = pango_layout_new(pangoctx);
      
      pango_layout_set_attributedString_with_options(_layout, string, options);
      
    _as = [string retain];
    _options = [options retain];
  }
  return self;
}

- (void) dealloc
{
  [_as release];
  [_options release];
    g_object_unref(_layout);
  [super dealloc];
}

- (CTLineRef)createLineWithRange: (CFRange)range offset:(CGFloat)offset
{
    
    CTLine *l = [[CTLine alloc] init];
    l.range = range;
    l.offset = offset;
    l.attributedString = _as;
    return l;

  // FIXME: This should do the core typesetting stuff:
  // - divide the attributed string into runs with the same attributes.
  // - run the bidirectional algorithm if needed
  // - call the shaper on each run
  
  NSArray *runs = [NSMutableArray array];
  
  CTLineRef line = [[CTLine alloc] initWithRuns: runs];
  return line;
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
    
    // FIXME: Why sometimes first line is 0 length?
    // find first none-zero length line, let it as first line
    if (bytesLength == 0) {
        int lineCount = pango_layout_get_line_count(layout);
        for (int lineIdx = 1; lineIdx<lineCount; lineIdx++) {
            firstLine = pango_layout_get_line_readonly(layout, lineIdx);
            bytesLength = firstLine->length;
            
            if (bytesLength > 0) {
                break;
            }
        }
    }
    
    // count number of glyphs in every run in line
    GList *l;
    gint glyphsCount = 0;
    for (l = firstLine->runs; l; l=l->next) {
        PangoLayoutRun *run = l->data;
        PangoGlyphString *glyphs = run->glyphs;
        glyphsCount += glyphs->num_glyphs;
    }
    
    g_object_unref(layout);
    g_object_unref(pangoctx);

    NSLog(@"suggest text count:%d ",glyphsCount);
    return glyphsCount;
}

@end


/* Functions */
#pragma mark - Functions

CTTypesetterRef CTTypesetterCreateWithAttributedString(CFAttributedStringRef string)
{
  return [[CTTypesetter alloc] initWithAttributedString: string
                                                options: nil];
}

CTTypesetterRef CTTypesetterCreateWithAttributedStringAndOptions(
	CFAttributedStringRef string,
	CFDictionaryRef opts)
{
  return [[CTTypesetter alloc] initWithAttributedString: string
                                                options: opts];
}

CTLineRef CTTypesetterCreateLine(CTTypesetterRef ts, CFRange range)
{
  return [ts createLineWithRange: range offset:0];
}

CTLineRef CTTypesetterCreateLineWithOffset(
                                           CTTypesetterRef typesetter,
                                           CFRange stringRange,
                                           double offset )
{
    return [typesetter createLineWithRange:stringRange offset:offset];
}

CFIndex CTTypesetterSuggestClusterBreak(
	CTTypesetterRef ts,
	CFIndex start,
	double width)
{
  return [ts suggestLineBreakAtIndex: start width: width];
}

CFIndex CTTypesetterSuggestLineBreak(
	CTTypesetterRef ts,
	CFIndex start,
	double width)
{
  return [ts suggestLineBreakAtIndex: start width: width];
}

CFIndex CTTypesetterSuggestLineBreakWithOffset(
                                               CTTypesetterRef typesetter,
                                               CFIndex startIndex,
                                               double width,
                                               double offset )
{
    double w = width - offset;
    return CTTypesetterSuggestLineBreak(typesetter, startIndex, w);
}

CFIndex CTTypesetterSuggestClusterBreakWithOffset(
                                                  CTTypesetterRef typesetter,
                                                  CFIndex startIndex,
                                                  double width,
                                                  double offset )
{
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return CTTypesetterSuggestClusterBreak(typesetter, startIndex, width);
    return 0;
}

CFTypeID CTTypesetterGetTypeID()
{
  return (CFTypeID)[CTTypesetter class];
}

