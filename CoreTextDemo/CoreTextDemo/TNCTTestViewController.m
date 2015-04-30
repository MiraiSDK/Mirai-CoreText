//
//  TNCTTestViewController.m
//  BasicCairo
//
//  Created by Chen Yonghui on 7/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork. All rights reserved.
//

#import "TNCTTestViewController.h"
#import "TNCTView.h"
#import <CoreText/CoreText.h>

@interface TNCTTestViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) TNCTView *ctView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray *actions;

@end

@implementation TNCTTestViewController

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSString *)testName
{
    return @"Core Text Test";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAttributedString *att = [self attributedStringWithFontSize:27];

    NSAttributedString *lineBreakAtt = [self lineBreakAttributedStringWithFontSize:27];
    
    NSAttributedString *indentAtt = [self indentAttributedStringWithFontSize:27];
    
    NSAttributedString *tabStopsAtt = [self tabStopsAttributedStringWithFontSize:27];
    
    NSAttributedString *lineHeightAtt = [self lineHeightAttributedStringWithFontSize:14];
    
    NSAttributedString *paraSpacingAtt = [self paraSpacingAttributedStringWithFontSize:17];
    
    NSAttributedString *diretionAtt = [self writeDirectionAttributedStringWithFontSize:20];
    
    NSAttributedString *paraStyleAtt = [self paraStyleAttributedStringWithFontSize:20];
    
    NSAttributedString *shapeAtt = [self pangoShapeAttributedStringWithFontSize:20];

    
    CGRect rect = CGRectInset(self.view.bounds, 0, 120);
//    TNCTView *v = [[TNCTView alloc] initWithFrame:rect];
//    v.attributedString = att;
//    [self.view addSubview:v];
//    v.hidden = YES;
//    self.ctView = v;
    
    UIView *bg = [[UIView alloc] initWithFrame:rect];
    bg.layer.borderWidth = 1;
    bg.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:bg];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
//    imageView.image = [self imageForAttributedString:att size:rect.size];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle_tap:)];
//    [self.view addGestureRecognizer:tap];
    
    __weak typeof(self) weakSelf = self;
    self.actions =
  @[
    [TNTestCase testCaseWithName:@"PangoShape" action:^{
        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:shapeAtt size:rect.size];
        imageView.image = image;
        
    }],
    [TNTestCase testCaseWithName:@"CTFrameDraw" action:^{
        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:att size:rect.size];
        imageView.image = image;

    }],
    [TNTestCase testCaseWithName:@"ParaStyle" action:^{
        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:paraStyleAtt size:rect.size];
        imageView.image = image;
        
    }],
//    [TNTestCase testCaseWithName:@"drawInRect" action:^{
//        UIImage *image = [weakSelf imageForAttributedString:att size:rect.size];
//        imageView.image = image;
//    }],
//    [TNTestCase testCaseWithName:@"CTLineBreakMode" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:lineBreakAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
//    [TNTestCase testCaseWithName:@"CTParaIndent" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:indentAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
//    [TNTestCase testCaseWithName:@"CTTextTabRef" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:tabStopsAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
//    [TNTestCase testCaseWithName:@"CTTextLineHeight" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:lineHeightAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
//    [TNTestCase testCaseWithName:@"CTTextParaSpacing" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:paraSpacingAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
//    [TNTestCase testCaseWithName:@"CTTextWriteDirection" action:^{
//        UIImage *image = [weakSelf imageCTFrameDrawForAttributedString:diretionAtt size:rect.size];
//        imageView.image = image;
//        
//    }],
    ];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), rect.size.width, self.view.bounds.size.height - CGRectGetMaxY(imageView.frame))];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressedClearItem:)];
    self.navigationItem.rightBarButtonItems = @[clearItem];
}

- (void)didPressedClearItem:(id)sender
{
    self.imageView.image = nil;
}


- (void)handle_tap:(UITapGestureRecognizer *)tap
{
    if (self.ctView.isHidden) {
        [self.view addSubview:self.ctView];
        [self.imageView removeFromSuperview];
        self.ctView.hidden = NO;
        self.imageView.hidden = YES;
    } else {
        [self.view addSubview:self.imageView];
        [self.ctView removeFromSuperview];
        self.ctView.hidden = YES;
        self.imageView.hidden = NO;
    }
}

- (UIImage *)imageCTFrameDrawForAttributedString:(NSAttributedString *)attr size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CTFramesetterRef fr = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attr);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    
    CGRect rect = {CGPointZero, size};
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    CTFrameRef f = CTFramesetterCreateFrame(fr, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(f, ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageForAttributedString:(NSAttributedString *)attr size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    [attr drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TNTestCase *tc = self.actions[indexPath.row];
    cell.textLabel.text = tc.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TNTestCase *tc = self.actions[indexPath.row];
    if (tc.action) {
        tc.action();
    }
}


#pragma mark - Text
#if __ANDROID__
#define TN_ARC_BRIDGE
#else
#define TN_ARC_BRIDGE (__bridge id)
#endif
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
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"　@不吃葱花教:很小的时候，没有适合自己的枕头，一直枕着母亲的手臂睡觉，一年又一年，那该有多难受...\n" attributes:@{
                                                                                                                                                            (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                            (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                            (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                 (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE style
                                                                                                                                                            }];
    
    
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"@张苏沛:初三的时候，晚上睡很晚，曾经一度晚上两三点才睡觉，当时没有电热毯，是我妈每天晚上先睡我床上为我暖被窝，等我写完作业，她才回她的房间睡。早上我一般是六点起床，我妈五点半就起来了，下楼给我买饭然后端上来给我吃，或者早起在家里自己给我做，从来没有塞给我几块钱让我下楼自己买。\n" attributes:@{
                                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor
                                                                                                                                                                                                                                        }];
    NSAttributedString *att2 = [[NSAttributedString alloc] initWithString:@"@小亲亲:记得上大一的时候，有一次随手在QQ个签上写了一句“好想回家”，这件事我很快就忘记了。很久之后，跟妈妈说话的时候，她跟我说，看见我写的那句" attributes:@{
                                                                                                                                                                    (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                    (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                    (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor blueColor].CGColor
                                                                                                                                                                    }];
    [att appendAttributedString:att1];
    [att appendAttributedString:att2];
    
//    CTParagraphStyleRef paragraphStyle = (TN_ARC_BRIDGE CTParagraphStyleRef)([att attribute:(TN_ARC_BRIDGE NSString *)(kCTParagraphStyleAttributeName) atIndex:0 effectiveRange:NULL]);
    
    return att;
    
}

- (NSAttributedString *)lineBreakAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    
    CTLineBreakMode lineBreakWordWrap = kCTLineBreakByWordWrapping;
    CTParagraphStyleSetting lineBreakWordWrapSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakWordWrap}
    };
    CTParagraphStyleRef lineBreakWordWrapStyle = CTParagraphStyleCreate(lineBreakWordWrapSettings, 1);

    CTLineBreakMode lineBreakCharWrap = kCTLineBreakByCharWrapping;
    CTParagraphStyleSetting lineBreakCharWrapSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakCharWrap}
    };
    CTParagraphStyleRef lineBreakCharWrapStyle = CTParagraphStyleCreate(lineBreakCharWrapSettings, 1);

    CTLineBreakMode lineBreakByClipping = kCTLineBreakByClipping;
    CTParagraphStyleSetting lineBreakByClippingSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakByClipping}
    };
    CTParagraphStyleRef lineBreakByClippingStyle = CTParagraphStyleCreate(lineBreakByClippingSettings, 1);
    
    CTLineBreakMode lineBreakByTruncatingHead = kCTLineBreakByTruncatingHead;
    CTParagraphStyleSetting lineBreakByTruncatingHeadSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakByTruncatingHead}
    };
    CTParagraphStyleRef lineBreakByTruncatingHeadStyle = CTParagraphStyleCreate(lineBreakByTruncatingHeadSettings, 1);
    
    CTLineBreakMode lineBreakByTruncatingTail = kCTLineBreakByTruncatingTail;
    CTParagraphStyleSetting lineBreakByTruncatingTailSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakByTruncatingTail}
    };
    CTParagraphStyleRef lineBreakByTruncatingTailStyle = CTParagraphStyleCreate(lineBreakByTruncatingTailSettings, 1);
    
    CTLineBreakMode lineBreakByTruncatingMiddle = kCTLineBreakByTruncatingMiddle;
    CTParagraphStyleSetting lineBreakByTruncatingMiddleSettings[] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakByTruncatingMiddle}
    };
    CTParagraphStyleRef lineBreakByTruncatingMiddleStyle = CTParagraphStyleCreate(lineBreakByTruncatingMiddleSettings, 1);
    
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This is line break with char wrapping This is line break with char wrapping \n" attributes:@{
                                                                                                                                                            (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                            (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                            (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                            (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakCharWrapStyle
                                                                                                                                                            }];
    
    
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"This is line break with word wrapping This is line break with word wrapping\n" attributes:@{
                                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor,
                                                                                                                                                                                                                                        (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakWordWrapStyle                                                                                                                         }];
    NSAttributedString *att2 = [[NSAttributedString alloc] initWithString:@"This is line break with clipping wrapping This is line break with clipping wrapping\n"attributes:@{
                                                                                                                                                                    (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                    (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                    (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor blueColor].CGColor,
                                                                                                                                                                    (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakByClippingStyle
                                                                                                                                                                    }];
    NSAttributedString *att3 = [[NSAttributedString alloc] initWithString:@"This is line break with Truncating head wrapping This is line break with Truncating head wrapping\n"attributes:@{
                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor redColor].CGColor,
                                                                                                                                                                               (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakByTruncatingHeadStyle
                                                                                                                                                                               }];
    NSAttributedString *att4 = [[NSAttributedString alloc] initWithString:@"This is line break with Truncating tail wrapping This is line break with Truncating tail wrapping\n"attributes:@{
                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor greenColor].CGColor,
                                                                                                                                                                               (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakByTruncatingTailStyle
                                                                                                                                                                               }];
    NSAttributedString *att5 = [[NSAttributedString alloc] initWithString:@"This is line break with Truncating middle wrapping This is line break with Truncating middle wrapping\n"attributes:@{
                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor blueColor].CGColor,
                                                                                                                                                                               (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineBreakByTruncatingMiddleStyle
                                                                                                                                                                               }];
    [att appendAttributedString:att1];
    [att appendAttributedString:att2];
    [att appendAttributedString:att3];
    [att appendAttributedString:att4];
    [att appendAttributedString:att5];
    
    return att;
    
}

- (NSAttributedString *)indentAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    CGFloat firstLineIndent = 15.0;
    CTParagraphStyleSetting firstLineIndentSettings[] = {
        kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&firstLineIndent
    };
    CTParagraphStyleRef firstLineIndentStyle = CTParagraphStyleCreate(firstLineIndentSettings, 1);
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This is for first line indent with 15.0 point, This is for first line indent with 15.0 point \n" attributes:@{
                                                                                                                                                            (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                            (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                            (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                            (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE firstLineIndentStyle
                                                                                                                                                            }];
    
    CGFloat headIndent = 15.0;
    CTParagraphStyleSetting headIndentSettings[] = {
        kCTParagraphStyleSpecifierHeadIndent,sizeof(CGFloat),&headIndent
    };
    CTParagraphStyleRef headIndentStyle = CTParagraphStyleCreate(headIndentSettings, 1);
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"This paragraph has 15.0 point head indent, This paragraph has 15.0 point head indent\n" attributes:@{
                                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor,
                                                                                                                                                                                                                                        (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE headIndentStyle
                                                                                                                                                                                                                                        }];
    
    CGFloat tailIndent = 150.0;
    CTParagraphStyleSetting tailIndentSettings[] = {
        kCTParagraphStyleSpecifierTailIndent,sizeof(CGFloat),&tailIndent
    };
    CTParagraphStyleRef tailIndentStyle = CTParagraphStyleCreate(tailIndentSettings, 1);
    NSAttributedString *att2 = [[NSAttributedString alloc] initWithString:@"This paragraph has 15.0 point tail indent, This paragraph has 15.0 point tail indent" attributes:@{
                                                                                                                                                                    (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                    (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                    (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName: TN_ARC_BRIDGE [UIColor blueColor].CGColor,
                                                                                                                                                                    (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE tailIndentStyle
                                                                                                                                                                    }];
    [att appendAttributedString:att1];
    [att appendAttributedString:att2];
    
    return att;
    
}

- (NSAttributedString *)tabStopsAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
//    
//    CFIndex i = 0;
//    CTTextTabRef tabArray[1];
//    CTTextAlignment align = 0;
//    CGFloat location = 80;
//    for (;i < 1; i++ ) {
//        tabArray[i] = CTTextTabCreate( align, location, NULL );
//    }
//    CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 1, &kCFTypeArrayCallBacks );
//    for (;i < 1; i++ ) { CFRelease( tabArray[i] ); }
//    
//    CTParagraphStyleSetting tabSettings[] =
//    {
//        { kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops },
//    };
//
//    CTParagraphStyleRef tabStopsStyle = CTParagraphStyleCreate(tabSettings, 1);
//    CGFloat tabInterval = 2.0;
//    CTParagraphStyleSetting tabSettings2[] =
//    {
//        { kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(CGFloat), &tabInterval }
//    };
//    CTParagraphStyleRef tabStopsStyle2 = CTParagraphStyleCreate(tabSettings2, 1);
//    
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
//    
//    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This \tis for text tab stop style with 80, \n\tThis is for text tab stop style with 80\n" attributes:@{
//                                                                                                                                                                                                      (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
//                                                                                                                                                                                                      (NSString *)kCTKernAttributeName:@(-0.02),
//                                                                                                                                                                                                      (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
//                                                                                                                                                                                                      (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE tabStopsStyle
//                                                                                                                                                                                                      }];
//    
//    NSMutableAttributedString *att1= [[NSMutableAttributedString alloc] initWithString:@"\tThis is for text tab stop style with 80 and default tab interval 2.0, \n\tThis is for text tab stop style with 80 and default tab interval 2.0\n" attributes:@{
//                                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
//                                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
//                                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
//                                                                                                                                                                                                                                        (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE tabStopsStyle2
//                                                                                                                                                                                                                                        }];
    
    NSMutableAttributedString *att2= [[NSMutableAttributedString alloc] initWithString:@"\tThis is for text tab stop style with default value, \n\tThis is for text tab stop style with default value\n" attributes:@{
                                                                                                                                                                                                      (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                      (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                      (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor                                                                                  }];
    
//    [att appendAttributedString:att1];
//    [att appendAttributedString:att2];
    
    return att2;
    
}


- (NSAttributedString *)lineHeightAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    
    CGFloat lineHeightMultiple = 3.0;
    CTParagraphStyleSetting lineHeightSettings1[] =
    {
        { kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple }
    };
    CTParagraphStyleRef lineHeightStyle1 = CTParagraphStyleCreate(lineHeightSettings1, 1);
    
    CGFloat maxLineHeight = 20;
    CTParagraphStyleSetting lineHeightSettings2[] =
    {
        { kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight },
    };
    CTParagraphStyleRef lineHeightStyle2 = CTParagraphStyleCreate(lineHeightSettings2, 2);
    
    CGFloat minLineHeight = 30;
    CTParagraphStyleSetting lineHeightSettings3[] =
    {
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight },
    };
    
    CTParagraphStyleRef lineHeightStyle3 = CTParagraphStyleCreate(lineHeightSettings3, 1);
    
    CGFloat lineSpaceing = 20;
    CTParagraphStyleSetting lineHeightSettings4[] =
    {
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpaceing },
    };
    
    CTParagraphStyleRef lineHeightStyle4 = CTParagraphStyleCreate(lineHeightSettings4, 1);
    
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This is default style, This is default style, This is default style\n" attributes:@{
                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                        }];
    
    NSMutableAttributedString *att1= [[NSMutableAttributedString alloc] initWithString:@"This is for line height multiple is 3.0, This is for line height multiple is 3.0\n" attributes:@{
                                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                                                               (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineHeightStyle1
                                                                                                                                                                                               }];
    
    NSMutableAttributedString *att2= [[NSMutableAttributedString alloc] initWithString:@"This is for line height multiple is 3.0 and max line height is 20, This is for line height multiple is 3.0 and max line height is 20\n" attributes:@{
                                                                                                                                                                                                                                                          (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                                                          (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                                          (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor blueColor].CGColor,
                                                                                                                                                                                                                                                          (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineHeightStyle2
                                                                                                                                                                                                                                                          }];
    
    NSMutableAttributedString *att3= [[NSMutableAttributedString alloc] initWithString:@"This is for min line height is 30, This is for min line height is 30,\n" attributes:@{
                                                                                                                                                                                                                      (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                      (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                      (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor,
                                                                                                                                                                                                                      (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineHeightStyle3                                                                                  }];
    NSMutableAttributedString *att4= [[NSMutableAttributedString alloc] initWithString:@"This is for line spacing 20, This is for line spacing 20,\n" attributes:@{
                                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor blueColor].CGColor,
                                                                                                                                                                               (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE lineHeightStyle4                                                                                  }];
    
    [att appendAttributedString:att1];
    [att appendAttributedString:att2];
    [att appendAttributedString:att3];
    [att appendAttributedString:att4];
    
    return att;
    
}

- (NSAttributedString *)paraSpacingAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    CGFloat paraSpacing = 20;
    CTParagraphStyleSetting paraSpacingSettings[] = {
        kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paraSpacing
    };
    CTParagraphStyleRef paraSpacingStyle = CTParagraphStyleCreate(paraSpacingSettings, 1);
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This is for paragraph spacing with 20 point, \nThis is for paragraph spacing with 20 point\n" attributes:@{
                                                                                                                                                                                                      (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                      (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                      (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                                                                      (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE paraSpacingStyle
                                                                                                                                                                                                      }];
    
    CGFloat paraSpacingBefore = 20.0;
    CTParagraphStyleSetting paraSpacingBeforeSettings[] = {
        kCTParagraphStyleSpecifierParagraphSpacingBefore,sizeof(CGFloat),&paraSpacingBefore
    };
    CTParagraphStyleRef paraSpacingBeforeStyle = CTParagraphStyleCreate(paraSpacingBeforeSettings, 1);
    NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"This is for paragraph spacing before with 20 point, \nThis is for paragraph spacing before with 20 point\n" attributes:@{
                                                                                                                                                                                 (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                 (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                 (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE [UIColor greenColor].CGColor,
                                                                                                                                                                                 (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE paraSpacingBeforeStyle
                                                                                                                                                                                 }];
    
    [att appendAttributedString:att1];
    return att;
    
}

- (NSAttributedString *)writeDirectionAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    CTWritingDirection direction = kCTWritingDirectionRightToLeft;
    CTParagraphStyleSetting directionSettings[] = {
        kCTParagraphStyleSpecifierBaseWritingDirection,sizeof(CTWritingDirection),&direction
    };
    CTParagraphStyleRef directionStyle = CTParagraphStyleCreate(directionSettings, 1);
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"This is right to left text, This is right to left text, This is right to left text, This is right to left text,\n" attributes:@{
                                                                                                                                                                                                   (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                   (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                   (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                                                                   (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE directionStyle
                                                                                                                                                                                                   }];
    return att;
    
}

- (NSAttributedString *)paraStyleAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    
    CGFloat paraSpacing = 20;
    CGFloat lineHeightMultiple = 3.0;
    CGFloat maxLineHeight = 20;
    CGFloat minLineHeight = 30;
    CGFloat lineSpaceing = 20;
    CTTextAlignment alignment = kCTTextAlignmentLeft;
    CTLineBreakMode lineBreakWordWrap = kCTLineBreakByWordWrapping;
    CGFloat firstLineIndent = 15.0;
    CGFloat headIndent = 15.0;
    CGFloat tailIndent = 250.0;

    
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&alignment},
        {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paraSpacing},
        { kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight },
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpaceing },
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakWordWrap},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&firstLineIndent},
        {kCTParagraphStyleSpecifierHeadIndent,sizeof(CGFloat),&headIndent},
        {kCTParagraphStyleSpecifierTailIndent,sizeof(CGFloat),&tailIndent},
    };
    CTParagraphStyleRef paraStyle = CTParagraphStyleCreate(settings, 10);
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"1. This is all para style test, This is all para style test,\n 2. This is all para style test, This is right to left text,\n" attributes:@{
                                                                                                                                                                                                                        (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                        (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                        (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                                                                                        (NSString *)                                                                           kCTParagraphStyleAttributeName: TN_ARC_BRIDGE paraStyle
                                                                                                                                                                                                                        }];
    return att;
    
}

static void deallocCallback(void * ref) {
    // do nothing under ARC
}

static CGFloat ascentCallback( void *ref ){
    return 40;
    
}

static CGFloat descentCallback( void *ref ){
    return 0;
}

static CGFloat widthCallback( void* ref ){
    return 120;
}

- (NSAttributedString *)pangoShapeAttributedStringWithFontSize:(CGFloat)size
{
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)([self fontAttributes]));
    CTFontRef font = CTFontCreateWithFontDescriptor(desc, size, NULL);
    
    UIColor *textColor = [UIColor colorWithRed:125.0f/255.0f green:159.0f/255.0f blue:132.0f/255.0f alpha:1];
    
    NSMutableAttributedString *att= [[NSMutableAttributedString alloc] initWithString:@"1. This is pango shape test, This is pango shape test," attributes:@{
                                                                                                                                                                                                                                   (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                                   (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                                   (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor}];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(self));
    
    NSMutableAttributedString *att1= [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{
                                                                                                                                                                                                                       (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                                                                                       (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                                                                                       (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor,
                                                                                                                                                                                                                       (NSString*)kCTRunDelegateAttributeName : TN_ARC_BRIDGE delegate}];
    NSMutableAttributedString *att2= [[NSMutableAttributedString alloc] initWithString:@"2. This is pango shape test, This is pango shape test," attributes:@{
                                                                                                                                                               (NSString *)kCTFontAttributeName:TN_ARC_BRIDGE font,
                                                                                                                                                               (NSString *)kCTKernAttributeName:@(-0.02),
                                                                                                                                                               (NSString *)                                                                                                                                                                                                                                                                                                           kCTForegroundColorAttributeName:TN_ARC_BRIDGE textColor.CGColor}];
    
    
    
//    NSDictionary *dict = @{
//                           NBAttachmentAttributeName : self,
//                           (__bridge NSString *)kCTRunDelegateAttributeName : CFBridgingRelease(delegate)
//                           };
//    
//    return dict;
    
//    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(self.object));
//
//    NSDictionary *dict = @{
//                           NBAttachmentAttributeName : self,
//                           (__bridge NSString *)kCTRunDelegateAttributeName : CFBridgingRelease(delegate)
//                           };
//    
//    [[NSAttributedString alloc] initWithString:NBAttachmentCharacterStr attributes:[attachment attributes]]
    [att appendAttributedString:att1];
    [att appendAttributedString:att2];
    return att;
    
}


- (NSDictionary *)fontAttributes
{
    return @{
             (NSString *)kCTFontFamilyNameAttribute : @"Helvetica",
             };
}

@end
