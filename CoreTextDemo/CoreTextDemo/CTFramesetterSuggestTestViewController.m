//
//  CTFramesetterSuggestTestViewController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 10/7/15.
//  Copyright © 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTFramesetterSuggestTestViewController.h"
#import <CoreText/CoreText.h>

@interface CTFramesetterSuggestTestViewController ()

@end

@implementation CTFramesetterSuggestTestViewController


+ (NSString *)testName
{
    return @"CTFramesetterSuggestFrameSizeWithConstraints()";
}

+ (void)load
{
    [self regisiterTestClass:self];
}


- (void)drawWithContext:(CGContextRef)ctx size:(CGSize)size
{
    NSAttributedString *as = [self attributedStringWithFontSize:20];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)as);
    CGFloat width = size.width;
    CGSize constraints = CGSizeMake(width, 2000);
    CFRange fitRange;
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, constraints, &fitRange);
    NSLog(@"%@",NSStringFromCGSize(suggestSize));
    
    
    CGRect suggestRect = CGRectMake(0, size.height-suggestSize.height, suggestSize.width, suggestSize.height);
    
    CGContextMoveToPoint(ctx, 0, size.height/2);
    CGContextAddLineToPoint(ctx, size.width, size.height/2);
    CGContextStrokePath(ctx);
    
    //mid
    suggestRect.origin.y -= (size.height - suggestSize.height) / 2;
    
    
    if (self.flip) {
        CGContextTranslateCTM(ctx, 0, size.height);
        CGContextScaleCTM(ctx, 1, -1);
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeRect(ctx, suggestRect);

    
    CGPathRef path = CGPathCreateWithRect(suggestRect, NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, ctx);

}

- (CGRect)imageRect
{
    return CGRectMake(50, 50, 200, 20);
}

- (NSDictionary *)fontAttributes
{
    return @{
             (NSString *)kCTFontFamilyNameAttribute : @"Helvetica",
             };
}

- (NSAttributedString *)attributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    
    CGFloat headIndent = 15.0;
    
    CTTextAlignment alignment = kCTTextAlignmentRight;
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierHeadIndent,sizeof(CGFloat),&headIndent},
        {kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&alignment},
        
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 2);
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *color = [UIColor blueColor];
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"　@不吃葱花教:\n" attributes:@{
                                                                                                                                                            (NSString *)kCTFontAttributeName:(__bridge id) font,                                                                                                                                                            (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:(__bridge id) textColor.CGColor                                                                                                                                                            }];
    
    
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"@张苏沛:初三的时候，晚上睡很晚，曾经一度晚上两三点才睡觉，当时没有电热毯，是我妈每天晚上先睡我床上为我暖被窝，等我写完作业，她才回她的房间睡。早上我一般是六点起床，我妈五点半就起来了，下楼给我买饭然后端上来给我吃，或者早起在家里自己给我做，从来没有塞给我几块钱让我下楼自己买。\n" attributes:@{
                                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:(__bridge id) font,
                                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:(__bridge id) [UIColor greenColor].CGColor
                                                                                                                                                                                                                                        }];
    NSAttributedString *att2 = [[NSAttributedString alloc] initWithString:@"@小亲亲:记得上大一的时候，有一次随手在QQ个签上写了一句“好想回家”，这件事我很快就忘记了。很久之后，跟妈妈说话的时候，她跟我说，看见我写的那句" attributes:@{
                                                                                                                                                                    (NSString *)kCTFontAttributeName:(__bridge id) font,
                                                                                                                                                                    (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                    (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: (__bridge id) [UIColor blueColor].CGColor
                                                                                                                                                                    }];
    //    [att appendAttributedString:att1];
    //    [att appendAttributedString:att2];
    
    //    CTParagraphStyleRef paragraphStyle = (TN_ARC_BRIDGE CTParagraphStyleRef)([att attribute:(TN_ARC_BRIDGE NSString *)(kCTParagraphStyleAttributeName) atIndex:0 effectiveRange:NULL]);
    
    return att;
    
    
}

@end
