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
#import "CTFramesetter-private.h"



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

+ (Class)framesetterClass
{
#if __ANDROID__
    return NSClassFromString(@"CTPangoFramesetter");
    
#endif
    return [CTFramesetter class];
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
    
    // set visible range
    
    // FIXME: take in to account CTTextTab settings (alignment, justification, etc?)

  switch ([[attributes objectForKey: kCTFrameProgressionAttributeName] intValue])
  {
    default:
    case kCTFrameProgressionTopToBottom:
    {
      CFIndex start = 0;
      while (start < [_string length])
      {
        CFIndex lineBreak = CTTypesetterSuggestLineBreak(_ts, start, frameRect.size.width);

        CTLineRef line = CTTypesetterCreateLine(_ts, CFRangeMake(start, lineBreak));
        [frame addLine: line];
        [line release];
        
        if (start == lineBreak)
          {
            NSLog(@"WARNING: Broke possible infinite loop in %s; string %@", __PRETTY_FUNCTION__, _string);
            break;
          }
        start = lineBreak;
      }
      break;
    }
    case kCTFrameProgressionRightToLeft:
      // FIXME: as above but for right to left, vertical text layout
      break;
  }

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
    return CGSizeZero;
}

@end


/* Functions */

CTFramesetterRef CTFramesetterCreateWithAttributedString(CFAttributedStringRef string)
{
  return [[[CTFramesetter framesetterClass] alloc] initWithAttributedString: string];
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
  return (CFTypeID)[CTFramesetter framesetterClass];
}
