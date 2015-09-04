//
//  CTPangoTypesetter.h
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTTypesetter-private.h"
#import <pango/pangocairo.h>

@interface CTPangoTypesetter : CTTypesetter
{
    PangoLayout *_layout;
}

@end
