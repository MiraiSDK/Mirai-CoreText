//
//  CTPangoRun.h
//  CoreText
//
//  Created by Chen Yonghui on 9/8/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTRun-private.h"
#import "CTPangoLine.h"
#import <pango/pango.h>

@interface CTPangoRun : CTRun
- (instancetype)initWithRun:(PangoLayoutRun *)run;
@property (nonatomic, assign) PangoLayoutRun *pangoRun;
@property (nonatomic, assign) CTPangoLine *line;
@property (nonatomic, assign) PangoRectangle logical_rect;
@property (nonatomic, assign) CFRange stringRange;
@property (nonatomic, assign) PangoLayout *layout;

@end
