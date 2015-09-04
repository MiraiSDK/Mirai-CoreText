//
//  CTPangoFrame.h
//  CoreText
//
//  Created by Chen Yonghui on 9/5/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "CTFrame-private.h"
#include <pango/pangocairo.h>

@interface CTPangoFrame : CTFrame
{
    PangoLayout *_layout;
}
@end
