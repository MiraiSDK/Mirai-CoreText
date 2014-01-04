//
//  CoreTextView.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 12/19/13.
//  Copyright (c) 2013 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CoreTextView.h"
#import <TNCoreText/CoreText.h>
@implementation CoreTextView
{
    NSString *_string;
    NSAttributedString *_attributedString;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _string = @"Hello Miku";
        _attributedString = [[NSAttributedString alloc] initWithString:_string attributes:[self attributes]];

    }
    return self;
}

- (void)awakeFromNib
{
    _string = @"Hello Miku";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:_string attributes:[self attributes]];
    
    CGColorRef blue = CGColorCreateGenericRGB(0, 0, 1, 1);
    [attr setAttributes:@{(__bridge NSString *)kCTForegroundColorAttributeName:(id)CFBridgingRelease(blue),} range:NSMakeRange(5, 4)];
    _attributedString = attr;
}

- (NSDictionary *)attributes
{
    CGColorRef redColor = CGColorCreateGenericRGB(1, 0, 0, 1);
    return @{
             (__bridge NSString *)kCTForegroundColorAttributeName:(id)CFBridgingRelease(redColor),
             (__bridge NSString *)kCTFontAttributeName:[NSFont systemFontOfSize:16]
             };
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

    [[NSColor blackColor] setFill];
    [NSBezierPath fillRect:self.bounds];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef f = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0),path,NULL);
    CTFrameDraw(f,ctx);


}

@end
