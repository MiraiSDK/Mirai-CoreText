//
//  NSAttributedString+Pango.h
//  CoreText
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pango/pango-layout.h>

@interface NSAttributedString (Pango)

@end

void pango_layout_set_attributedString(PangoLayout *layout,
                                       NSAttributedString *as);

void pango_layout_set_attributedString_with_options(PangoLayout *layout,
                                       NSAttributedString *as,
                                       NSDictionary *options);
