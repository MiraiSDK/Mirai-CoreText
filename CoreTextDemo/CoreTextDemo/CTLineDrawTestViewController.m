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
@property (nonatomic, assign) BOOL flip;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CTLineDrawTestViewController

+ (NSString *)testName
{
    return @"CTLineDraw()";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat side = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect rect = CGRectMake(0, 0, side, side);
    rect = CGRectInset(rect, 20, 20);
    UIImageView *iv = [[UIImageView alloc] initWithFrame:rect];
    iv.center = CGPointMake(self.view.bounds.size.width/2,
                            self.view.bounds.size.height/2);
    iv.backgroundColor = [UIColor lightGrayColor];
    iv.image = [self generateImageWithSize:rect.size];
    iv.layer.borderWidth = 1;
    self.imageView = iv;
    [self.view addSubview:iv];
    
    
    UIBarButtonItem *flip = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressedFlipItem:)];
    self.navigationItem.rightBarButtonItems = @[flip];
    
}

- (void)didPressedFlipItem:(id)sender
{
    self.flip = !self.flip;
    [self updateImage];
}

- (void)updateImage
{
    self.imageView.image = [self generateImageWithSize:self.imageView.bounds.size];
}

- (UIImage *)generateImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [self drawWithContext:UIGraphicsGetCurrentContext() size:size];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
