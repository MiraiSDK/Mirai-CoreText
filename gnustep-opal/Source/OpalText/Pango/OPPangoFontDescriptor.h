//
//  OPPangoFontDescriptor.h
//  CoreText
//
//  Created by Chen Yonghui on 4/12/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "OPFontDescriptor.h"
#import <pango/pango.h>

@interface OPPangoFontDescriptor : OPFontDescriptor {
    PangoFontDescription *_desc;
}

- (PangoFontDescription *)pangoDesc;
@end
