//
//  OPPangoFont.m
//  CoreText
//
//  Created by Chen Yonghui on 7/20/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "OPPangoFont.h"
#import <pango/pango.h>
#import <pango/pangocairo.h>
#import "OPPangoFontDescriptor.h"

@interface OPPangoFont ()

@end

@implementation OPPangoFont
{
    PangoFont *_font;
    PangoFontDescription *_desc;
    OPFontDescriptor *_creatFrom;
    PangoContext *_context;
}
- (id)_initWithDescriptor: (OPFontDescriptor*)aDescriptor
                  options: (CTFontOptions)options
{
    self = [super _initWithDescriptor:aDescriptor options:options];
    if (self) {
        _creatFrom = [aDescriptor retain];

        PangoFontMap *fontMap = pango_cairo_font_map_get_default();
        PangoContext *pangoctx = pango_font_map_create_context(fontMap);
        _context = pangoctx;

        OPPangoFontDescriptor *desc = aDescriptor;
        NSLog(@"[OPPangoFont] create with desc:%@",desc);
        NSLog(@"[OPPangoFont] font family name:%@",[desc objectForKey:kCTFontFamilyNameKey]);
        _font = pango_font_map_load_font(fontMap, pangoctx, desc.pangoDesc);
        _desc = pango_font_describe(_font);
        
        const char *familyName = pango_font_description_get_family(_desc);
        NSLog(@"[OPPangoFont] loaded font:%s",familyName);

        static BOOL oneTimeDebug = NO;
        if (!oneTimeDebug) {
            oneTimeDebug = YES;
            NSLog(@"=======> DEBUG <======");
            
            int i;
            PangoFontFamily ** families;
            int n_families;
            PangoFontMap * fontmap;
            
            fontmap = pango_cairo_font_map_get_default();
            pango_font_map_list_families (fontmap, & families, & n_families);
            NSLog(@"There are %d families\n", n_families);
            for (i = 0; i < n_families; i++) {
                PangoFontFamily * family = families[i];
                const char * family_name;
                
                family_name = pango_font_family_get_name (family);
                NSLog(@"Family %d: %s\n", i, family_name);
            }
            g_free (families);
            NSLog(@"=======> DEBUG END <======");
        }

        

    }
    return self;
}

- (void)dealloc
{
    [_creatFrom release];
    
    g_object_unref(_context);
    g_object_unref(_font);
    g_object_unref(_desc);
    
    [super dealloc];
}


- (NSString*) nameForKey: (NSString*)nameKey
{
    NSLog(@"%s %@",__PRETTY_FUNCTION__, nameKey);
    if ([nameKey isEqualToString:(NSString *)kCTFontFamilyNameKey]) {
        const char *familyName = pango_font_description_get_family(_desc);
        NSString *str = [[NSString alloc] initWithCString:familyName encoding:NSUTF8StringEncoding];
        return str;
    } else {
        NSLog(@"[CTFont]get value of key: %@ unimplemented",nameKey);
    }
    
    return nil;
}

@end
