//
//  OPPangoFontDescriptor.m
//  CoreText
//
//  Created by Chen Yonghui on 4/12/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "OPPangoFontDescriptor.h"
#import <pango/pango.h>

@implementation OPPangoFontDescriptor
{
    PangoFontDescription *_desc;
}

- (id)initWithFontAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _desc = pango_font_description_new();
    }
    return self;
}

- (void)dealloc
{
    pango_font_description_free(_desc);
    
    [super dealloc];
}

- (NSString *)postscriptName
{
    return nil;
}


@end
