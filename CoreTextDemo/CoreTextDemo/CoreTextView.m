//
//  CoreTextView.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 12/19/13.
//  Copyright (c) 2013 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CoreTextView.h"
#import <CoreText/CoreText.h>
#import <CoreText/CTFramesetter.h>


@implementation CoreTextView
{
    NSString *_string;
    NSAttributedString *_attributedString;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _string = @"Hello Miku";
        _attributedString = [[NSAttributedString alloc] initWithString:_string attributes:[self attributes]];
    }
    return self;
}

- (NSDictionary *)attributes
{
    return @{
             NSForegroundColorAttributeName:[UIColor redColor],
             NSFontAttributeName:[UIFont systemFontOfSize:16]
             };
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef f = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0),path,NULL);
    CTFrameDraw(f,UIGraphicsGetCurrentContext());
}


@end
