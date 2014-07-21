/** <title>CTLine</title>

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

#import "CTLine-private.h"

#import <pango/pango.h>
#import "PangoCoreGraphics-render.h"
#import <pango/pangocairo.h>
#import "NSAttributedString+Pango.h"

/* Classes */

@implementation CTLine

- (id)initWithRuns: (NSArray*)runs
{
  if ((self = [super init]))
  {
    _runs = [runs retain];
  }
  return self;
}

- (NSArray*)runs
{
  return _runs;
}

- (void)drawOnContext: (CGContextRef)ctx
{
    if (self.attributedString) {
        CGContextSaveGState(ctx);
        
        NSLog(@"str:%@ length:%d",self.attributedString.string,self.attributedString.length);
        NSLog(@"lineRange:{%d,%d}",self.range.location,self.range.length);
        NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];

        // prepare pango 
        PangoFontMap *fm = pango_cairo_font_map_new();
        PangoContext *pangoCtx = pango_font_map_create_context(fm);
        PangoLayout *layout = pango_layout_new(pangoCtx);
        pango_layout_set_attributedString(layout, lineAS);
        pango_layout_set_single_paragraph_mode(layout, true);
        
        // calculate line rect
        CGPoint textPosition = CGContextGetTextPosition(ctx);
        int width,height;
        pango_layout_get_pixel_size(layout, &width, &height);
        CGRect rect = CGRectMake(textPosition.x, textPosition.y - height, width, height);
        
        NSLog(@"draw line at rect:{{%.2f,%.2f},{%.2f,%.2f}} str:%@",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height,lineAS.string);
        
        pango_coregraphics_show_layout_in_rect(ctx, layout, rect);
        
        g_object_unref(layout);
        
        CGContextRestoreGState(ctx);
    } else {
        const NSUInteger runsCount = [_runs count];
        for (NSUInteger i=0; i<runsCount; i++)
        {
            CTRunRef run = [_runs objectAtIndex: i];
            CTRunDraw(run, ctx, CFRangeMake(0, 0));
        }
    }
}

- (CFIndex)glyphCount
{
  CFIndex sum = 0;
  const NSUInteger runsCount = [_runs count];
  for (NSUInteger i=0; i<runsCount; i++)
  {
    CTRunRef run = [_runs objectAtIndex: i];
    sum += CTRunGetGlyphCount(run);
  }
  return sum;
}

- (NSArray*)glyphRuns
{
  return _runs;
}

- (CTLine*) truncatedLineWithWidth: (double)width
                    truncationType: (CTLineTruncationType)truncationType
                   truncationToken:	(CTLineRef)truncationToken
{
  return nil;
}

- (double)penOffset
{
  return 0;
}

- (CFRange)stringRange
{
  return CFRangeMake(0,0);
}
@end


/* Functions */

CTLineRef CTLineCreateWithAttributedString(CFAttributedStringRef string)
{
  CTTypesetterRef ts = CTTypesetterCreateWithAttributedString(string);
  CTLineRef line = CTTypesetterCreateLine(ts, CFRangeMake(0, 0));
  [ts release];
  return line;
}

CTLineRef CTLineCreateTruncatedLine(
	CTLineRef line,
	double width,
	CTLineTruncationType truncationType,
	CTLineRef truncationToken)
{
  return [[line truncatedLineWithWidth: width
                        truncationType: truncationType
                       truncationToken: truncationToken] retain];
}

CTLineRef CTLineCreateJustifiedLine(
	CTLineRef line,
	CGFloat justificationFactor,
	double justificationWidth)
{
  return line;
}

CFIndex CTLineGetGlyphCount(CTLineRef line)
{
  return [line glyphCount];
}

CFArrayRef CTLineGetGlyphRuns(CTLineRef line)
{
  return [line glyphRuns];
}

CFRange CTLineGetStringRange(CTLineRef line)
{
  return [line stringRange];
}

double CTLineGetPenOffsetForFlush(
	CTLineRef line,
	CGFloat flushFactor,
	double flushWidth)
{
  return [line penOffset];
}
void CTLineDraw(CTLineRef line, CGContextRef context)
{
  return [line drawOnContext: context];
}

CGRect CTLineGetImageBounds(
	CTLineRef line,
	CGContextRef context)
{
  return CGRectMake(0,0,0,0);
}

double CTLineGetTypographicBounds(
	CTLineRef line,
	CGFloat* ascent,
	CGFloat* descent,
	CGFloat* leading)
{
    if (ascent) {
        *ascent = 0;
    }
    
    if (descent) {
        *descent = 0;
    }
    
    if (leading) {
        *leading = 0;
    }
  return 0;
}

double CTLineGetTrailingWhitespaceWidth(CTLineRef line)
{
  return 0;
}

CFIndex CTLineGetStringIndexForPosition(
	CTLineRef line,
	CGPoint position)
{
  return 0;
}

CGFloat CTLineGetOffsetForStringIndex(
	CTLineRef line,
	CFIndex charIndex,
	CGFloat* secondaryOffset)
{
  return 0;
}

CFTypeID CTLineGetTypeID()
{
  return (CFTypeID)[CTLine class];
}

