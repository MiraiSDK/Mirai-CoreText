//
//  CTLineDrawTestViewController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 9/8/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTLineDrawTestViewController.h"
#import <CoreText/CoreText.h>

@interface CTLineDrawTestViewController ()
@end

@implementation CTLineDrawTestViewController

+ (NSString *)testName
{
    return @"CTLineDraw()";
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
    CTLineDraw(line, ctx);
    
    //top-right
    CGContextSetTextPosition(ctx, rightX, 0);
    CTLineDraw(line, ctx);
    
    //mid-left
    CGContextSetTextPosition(ctx, 0, size.height/2);
    CTLineDraw(line, ctx);
    
//    //mid-right
//    CGContextSetTextPosition(ctx, rightX, size.height/2);
//    CTLineDraw(line, ctx);
    
    //bottom-left
    CGContextSetTextPosition(ctx, 0, size.height-lineHeight);
    CTLineDraw(line, ctx);
    
    //bottom-right
//    CGContextSetTextPosition(ctx, rightX, size.height-lineHeight);
//    CTLineDraw(line, ctx);
}

@end
