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

#import "CTTypesetter-private.h"

#import "CTLine-private.h"
// FIXME: use advanced layout engines if available
#import "OPSimpleLayoutEngine.h"

/* Constants */

const CFStringRef kCTTypesetterOptionDisableBidiProcessing = @"kCTTypesetterOptionDisableBidiProcessing";
const CFStringRef kCTTypesetterOptionForcedEmbeddingLevel = @"kCTTypesetterOptionForcedEmbeddingLevel";

@implementation CTTypesetter
- (id)initWithAttributedString: (NSAttributedString*)string
                       options: (NSDictionary*)options
{
  if ((self = [super init]))
  {
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

- (CTLineRef)createLineWithRange: (CFRange)range offset:(CGFloat)offset
{
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
    return 0;
}

- (CFIndex)suggestLineBreakAtIndex: (CFIndex)start
                             width: (double)width
{
    return 0;
}

- (Class)typesetterClass
{
#if __ANDROID__
    return NSClassFromString(@"CTPangoTypesetter");
#endif
    return [CTTypesetter class];
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

