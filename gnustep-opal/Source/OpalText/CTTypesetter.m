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

#import "CTLine-private.h"
// FIXME: use advanced layout engines if available
#import "OPSimpleLayoutEngine.h"

#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>

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
}

- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options;

- (CTLineRef)createLineWithRange: (CFRange)range;
- (CFIndex)suggestClusterBreakAtIndex: (CFIndex)start
                                width: (double)width;
- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width;

@end

@implementation CTTypesetter {
    PangoLayout *_layout;
}

- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options
{
  if ((self = [super init]))
  {
      PangoFontMap *fontmap = pango_cairo_font_map_new();
      PangoContext *pangoctx = pango_font_map_create_context(fontmap);
      _layout = pango_layout_new(pangoctx);
      
      // FIXME: set attrubites
      NSLog(@"[%@]init with string:%@ ",self.class,string.string);
      
      pango_layout_set_text(_layout, string.string.UTF8String, string.string.length);
      
    _as = [string retain];
    _options = [options retain];
  }
  return self;
}

- (void) dealloc
{
  [_as release];
  [_options release];
  [super dealloc];
}

- (CTLineRef)createLineWithRange: (CFRange)range
{
  // FIXME: This should do the core typesetting stuff:
  // - divide the attributed string into runs with the same attributes.
  // - run the bidirectional algorithm if needed
  // - call the shaper on each run
  
  NSArray *runs = [NSMutableArray array];
  
  CTLineRef line = [[CTLine alloc] initWithRuns: runs];
  return line;
}

- (CFIndex)suggestClusterBreakAtIndex: (CFIndex)start
                                width: (double)width
{
    NSLog(@"%s unimplemented: idx:%d,%.2f",__PRETTY_FUNCTION__,start,width);
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
    NSLog(@"suggest: %d",clusterIdx);
  return clusterIdx;
}
- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width
{
    NSLog(@"%s unimplemented: idx:%d,%.2f",__PRETTY_FUNCTION__,start,width);
    PangoLayoutIter *iter = pango_layout_get_iter(_layout);
    int lineIdx = 0;
    while (lineIdx <= start) {
        bool su = pango_layout_iter_next_line(iter);
        lineIdx = pango_layout_iter_get_index(iter);
        
        if (!su) {
            lineIdx = _as.string.length;
            break;
        }
    }
    
    pango_layout_iter_free(iter);
    NSLog(@"suggest: %d",lineIdx);
    return lineIdx;
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
  return [ts createLineWithRange: range];
}

CTLineRef CTTypesetterCreateLineWithOffset(
                                           CTTypesetterRef typesetter,
                                           CFRange stringRange,
                                           double offset )
{
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return CTTypesetterCreateLine(typesetter, stringRange);
}

CFIndex CTTypesetterSuggestClusterBreak(
	CTTypesetterRef ts,
	CFIndex start,
	double width)
{
  return [ts suggestClusterBreakAtIndex: start width: width];
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
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return CTTypesetterSuggestLineBreak(typesetter, startIndex, width);
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

