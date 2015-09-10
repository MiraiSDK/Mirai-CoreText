//
//  CTRunDrawTestViewController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 9/9/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTRunDrawTestViewController.h"
#import <CoreText/CoreText.h>

@implementation CTRunDrawTestViewController
+ (NSString *)testName
{
    return @"CTRunDraw()";
}

- (void)drawLine:(CTLineRef)line inContext:(CGContextRef)context attributedString:(NSAttributedString *)attributedString
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSArray *runs = (__bridge NSArray *)CTLineGetGlyphRuns(line);
    for (id r in runs) {
        CTRunRef run = (__bridge CTRunRef)(r);
        CFRange runRange = CTRunGetStringRange(run);
        NSNumber *superscript = [attributedString attribute:(__bridge NSString *)kCTSuperscriptAttributeName atIndex:runRange.location effectiveRange:NULL];
        if ([superscript floatValue] >0) {
            CGContextSaveGState(context);
            CGFloat runAscent,runDescent;
            CGFloat lineAscent,lineDescent;
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
            CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            CGFloat scriptOffset = lineAscent + lineDescent - runAscent - runDescent;
            CGContextTranslateCTM(context, 0, scriptOffset);
            CTRunDraw(run, context, CFRangeMake(0, 0));
            CGContextRestoreGState(context);
        } else {
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
    }
}

- (void)drawWithContext:(CGContextRef)ctx size:(CGSize)size
{
    // CTLine
    
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"Hello World"];
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(att));
    
    CGFloat ascent,descent;
    CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
    CGFloat lineHeight = ascent + descent;
    
    // draw mid line
    CGFloat midY = size.height / 2;
    CGFloat midX = size.width / 2;
    CGContextMoveToPoint(ctx, 0, midY);
    CGContextAddLineToPoint(ctx, size.width, midY);
    CGContextMoveToPoint(ctx, midX, 0);
    CGContextAddLineToPoint(ctx, midX, size.height);
    CGContextStrokePath(ctx);
    
    
    //text drawing prepare
    if (self.flip) {
        CGContextTranslateCTM(ctx, 0, size.height);
        CGContextScaleCTM(ctx, 1, -1);
    }
    
    CGFloat rightX = size.width - lineWidth;
    
    //top-left
    CGContextSetTextPosition(ctx, 0, 0);
    [self drawLine:line inContext:ctx attributedString:att];
    
    //top-right
    CGContextSetTextPosition(ctx, rightX, 0);
    [self drawLine:line inContext:ctx attributedString:att];
    
    //mid-left
    CGContextSetTextPosition(ctx, 0, size.height/2);
    [self drawLine:line inContext:ctx attributedString:att];
    
    //bottom-left
    CGContextSetTextPosition(ctx, 0, size.height-lineHeight);
    [self drawLine:line inContext:ctx attributedString:att];
    
}
@end
