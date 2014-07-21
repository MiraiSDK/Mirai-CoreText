//
//  OPPangoFontDescriptor.m
//  CoreText
//
//  Created by Chen Yonghui on 4/12/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "OPPangoFontDescriptor.h"
#import <pango/pango.h>
#import "CTFont.h"

@implementation OPPangoFontDescriptor


- (id)initWithFontAttributes:(NSDictionary *)attributes
{
    self = [super initWithFontAttributes:attributes];
    if (self) {
        _desc = pango_font_description_new();
        
        NSString *fontFamilyName = attributes[OPFontFamilyAttribute];
        if (fontFamilyName) {
            pango_font_description_set_family(_desc, fontFamilyName.UTF8String);
        }

    }
    return self;
}

- (void)dealloc
{
    pango_font_description_free(_desc);
    [super dealloc];
}

- (PangoFontDescription *)pangoDesc
{
    return _desc;
}

- (id)objectFromPlatformFontPatternForKey:(NSString *)key
{
    id obj = nil;
    if ([key isEqualToString:(NSString *)kCTFontFamilyNameKey]) {
        const char *family = pango_font_description_get_family(_desc);
        NSString *str = [[NSString alloc] initWithCString:family encoding:NSUTF8StringEncoding];
        obj = str;
    }
    
    return obj;

}

- (id) localizedObjectFromPlatformFontPatternForKey: (NSString*)key language: (NSString*)language
{
    id obj = nil;
    if ([key isEqualToString:(NSString *)kCTFontFamilyNameKey]) {
        const char *family = pango_font_description_get_family(_desc);
        NSString *str = [[NSString alloc] initWithCString:family encoding:NSUTF8StringEncoding];
        obj = str;
    }
    
    return obj;
}


@end
