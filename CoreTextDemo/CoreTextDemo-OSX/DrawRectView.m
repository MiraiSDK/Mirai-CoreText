//
//  DrawRectView.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 6/25/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "DrawRectView.h"
#import <TNCoreText/CoreText.h>

@implementation DrawRectView
{
    NSString *_string;
    NSAttributedString *_attributedString;
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _string = @"Hello Miku Hello Miku";
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:_string attributes:[self attributes]];
        
        CGColorRef blue = CGColorCreateGenericRGB(0, 0, 1, 1);
        [attr setAttributes:@{(__bridge NSString *)kCTForegroundColorAttributeName:(id)CFBridgingRelease(blue),} range:NSMakeRange(5, 4)];
        _attributedString = attr;
    }
    return self;
}

- (NSDictionary *)attributes
{
    CGColorRef redColor = CGColorCreateGenericRGB(1, 0, 0, 1);
    CTTextAlignment textAlign = kCTTextAlignmentCenter;
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment), &textAlign },
    };
    CTParagraphStyleRef paragraphStryle = CTParagraphStyleCreate(settings, 1);
    
    return @{
             (__bridge NSString *)kCTForegroundColorAttributeName:(id)CFBridgingRelease(redColor),
             (__bridge NSString *)kCTFontAttributeName:[NSFont systemFontOfSize:16],
             (__bridge NSString *)kCTParagraphStyleAttributeName:(__bridge id)paragraphStryle,
             };
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
//    [[NSColor blackColor] setFill];
//    [NSBezierPath fillRect:self.bounds];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    NSLog(@"suggesting size..");
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, self.bounds.size, NULL);
    NSLog(@"------>suggest size:{%.2f,%.2f}",size.width,size.height);
    
    CGRect drawRect = CGRectMake(0, 0, 320, 100);
    drawRect.size = size;
    
    [[NSColor blueColor] setStroke];
    CGContextStrokeRect(ctx, drawRect);

    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawRect);
    
    CTFrameRef f = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0),path,NULL);
    CTFrameDraw(f,ctx);
    
}

@end
