//
//  NSAttributedString+Pango.h
//  CoreText
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pango/pango-layout.h>

// NSString use UTF-16
// Pango use UTF-8
@interface NSString (TNIndexConvert)
- (NSUInteger)UTF8IndexForIndex:(NSUInteger)index;
- (NSUInteger)indexForUTF8Index:(NSUInteger)index;

- (NSUInteger)pangoIndexForStringIndex:(NSUInteger)index;
- (NSUInteger)stringIndexForPangoIndex:(NSUInteger)index;
@end

@interface NSAttributedString (Pango)

@end

void pango_layout_set_attributedString(PangoLayout *layout,
                                       NSAttributedString *as);

void pango_layout_set_attributedString_with_options(PangoLayout *layout,
                                       NSAttributedString *as,
                                       NSDictionary *options);
