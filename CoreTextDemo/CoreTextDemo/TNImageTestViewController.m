//
//  TNImageTestViewController.m
//  
//
//  Created by Chen Yonghui on 9/9/15.
//
//

#import "TNImageTestViewController.h"

@implementation TNImageTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [self imageRect];
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

- (CGRect)imageRect
{
    CGFloat side = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect rect = CGRectMake(0, 0, side, side);
    rect = CGRectInset(rect, 20, 20);
    return rect;
}

- (void)updateImage
{
    self.imageView.image = [self generateImageWithSize:self.imageView.bounds.size];
}

- (void)didPressedFlipItem:(id)sender
{
    self.flip = !self.flip;
    [self updateImage];
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
}
@end
