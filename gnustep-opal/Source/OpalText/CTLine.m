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

- (void)dealloc
{
    [_runs release];
    [_attributedString release];
    [super dealloc];
}

- (void)drawOnContext: (CGContextRef)ctx
{
    if (self.attributedString) {
        CGContextSaveGState(ctx);
        
        NSLog(@"str:%@ length:%d",self.attributedString.string,self.attributedString.length);
        NSLog(@"lineRange:{%d,%d}",self.range.location,self.range.length);
        NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];

        // prepare pango 
        PangoFontMap *fm = pango_cairo_font_map_get_default();
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
        g_object_unref(pangoCtx);
        
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

- (CGFloat)width
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];

    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);

    int width,height;
    pango_layout_get_pixel_size(layout, &width, &height);

    g_object_unref(layout);
    g_object_unref(pangoCtx);
 
    return width;
}

- (CGFloat) offsetForIndex:(CFIndex) charIndex
           secondaryOffset:(CGFloat*) secondaryOffset
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);

    PangoRectangle rect;
    
    NSString * str = [lineAS string];
    signed long charIndexInLine = charIndex - self.range.location;
    if (charIndexInLine < 0) {
        charIndexInLine = 0;
    }
    charIndexInLine = [str UTF8IndexForIndex:charIndexInLine];
    
    pango_layout_index_to_pos(layout, (int)charIndexInLine, &rect);
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    CGFloat offset = rect.x / PANGO_SCALE;
    if (secondaryOffset) {
        *secondaryOffset = offset;
    }
    return offset;
}

- (CFRange)stringRange
{
  return CFRangeMake(0,0);
}

- (CFIndex)stringIndexForPosition:(CGPoint)point
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    NSString *lineStr = lineAS.string;
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);

    int x = point.x * PANGO_SCALE;
    int y = point.y * PANGO_SCALE;
    int index,trailing;
    pango_layout_xy_to_index(layout,x,y,&index,&trailing);
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);
    
    CFIndex UTF16Index = (CFIndex)[lineStr indexForUTF8Index:index];
    return self.range.location + UTF16Index;
}

- (double)getTypographicBoundsAscent:(CGFloat *)ascent descent:(CGFloat *)descent leading:(CGFloat *)leading
{
    NSAttributedString *lineAS = [self.attributedString attributedSubstringFromRange:NSMakeRange(self.range.location, self.range.length)];
    
    PangoFontMap *fm = pango_cairo_font_map_get_default();
    PangoContext *pangoCtx = pango_font_map_create_context(fm);
    PangoLayout *layout = pango_layout_new(pangoCtx);
    pango_layout_set_attributedString(layout, lineAS);
    pango_layout_set_single_paragraph_mode(layout, true);

    int width,height;
    pango_layout_get_pixel_size(layout,&width,&height);
    
    if (ascent) {
        *ascent = height;
    }
    if (descent) {
        *descent = 0;
    }
    
    if (leading) {
        *leading = 0;
    }
    
    g_object_unref(layout);
    g_object_unref(pangoCtx);

    return width;
}
@end


/* Functions */

CTLineRef CTLineCreateWithAttributedString(CFAttributedStringRef string)
{
  CTTypesetterRef ts = CTTypesetterCreateWithAttributedString(string);
  CTLineRef line = CTTypesetterCreateLine(ts, CFRangeMake(0, CFAttributedStringGetLength(string)));
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
  return [line retain];
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
    CGFloat lineWidth = [line width];
    CGFloat gap = flushWidth - lineWidth;
    CGFloat offset = gap * flushFactor;
    return offset;
    
    //return [line penOffset];
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
    return [line getTypographicBoundsAscent:ascent descent:descent leading:leading];
}

double CTLineGetTrailingWhitespaceWidth(CTLineRef line)
{
  return 0;
}

CFIndex CTLineGetStringIndexForPosition(
	CTLineRef line,
	CGPoint position)
{
    return [(CTLine *)line stringIndexForPosition:position];
}

CGFloat CTLineGetOffsetForStringIndex(
	CTLineRef line,
	CFIndex charIndex,
	CGFloat* secondaryOffset)
{
  return [line offsetForIndex:charIndex secondaryOffset:secondaryOffset];
}

CFTypeID CTLineGetTypeID()
{
  return (CFTypeID)[CTLine class];
}

