//
//  NSAttributedString+Pango.m
//  CoreText
//
//  Created by Chen Yonghui on 5/2/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "NSAttributedString+Pango.h"

#include <CoreText/CTRunDelegate.h>
#include <CoreText/CTParagraphStyle.h>

#import "CTStringAttributes.h"
#import "CTFont.h"
#import "CTFoundationExtended.h"


@implementation NSAttributedString (Pango)

- (void)configurePangoLayout:(PangoLayout *)layout options:(NSDictionary *)options
{
    // set text
    pango_layout_set_text(layout, self.string.UTF8String, self.string.length);

    // setting attributes
    CTParagraphStyleRef paragraphStyle = [self attribute:kCTParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
    CTTextAlignment alignment;
    CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment);
    if (alignment == kCTTextAlignmentJustified) {
        pango_layout_set_justify(layout, true);
    } else {
        PangoAlignment pangoAlignment = PANGO_ALIGN_LEFT;
        switch (alignment) {
            case kCTTextAlignmentLeft: pangoAlignment = PANGO_ALIGN_LEFT; break;
            case kCTTextAlignmentCenter: pangoAlignment = PANGO_ALIGN_CENTER; break;
            case kCTTextAlignmentRight: pangoAlignment = PANGO_ALIGN_RIGHT; break;
                
            default:break;
        }
        pango_layout_set_alignment(layout, pangoAlignment);
    }

    PangoAttrList *attrList = pango_attr_list_new();;
    [self fillAttributeList:attrList withAttributedString:self];
    pango_layout_set_attributes(layout, attrList);
    
    const PangoFontDescription *fontDescription =pango_font_description_from_string("Droid Sans Fallback Regular 12");
    pango_layout_set_font_description(layout, fontDescription);
}

#pragma mark - Attributes
- (PangoAttribute *)createPangoFontAttributeFromNSAttributedValue:(id)obj
{
    const char *family = "Droid Sans Fallback";
    int size = 12;
    
    if ([obj isKindOfClass:NSClassFromString(@"NSFont")]) {
        
    } else if ([obj isKindOfClass:NSClassFromString(@"UIFont")]) {
        CTFontRef font = [obj _CTFont];
        size = CTFontGetSize(font);
        CFStringRef f = CTFontCopyFamilyName(obj);
        family = [f UTF8String];
    } else if ([obj isKindOfClass:NSClassFromString(@"OPFont")]){
        size = CTFontGetSize(obj);
        CFStringRef f = CTFontCopyFamilyName(obj);
        family = [f UTF8String];
    } else {
        NSLog(@"[PangoAttribute]unknow font value:%@",obj);
    }
    
    
    if (family == NULL) {
        NSLog(@"[PangoAttribute][Warning]Create font with NULL family name, set to 12 Droid Sans Fallback");
        family = "Droid Sans Fallback";
    }
    
    if (size == 0) {
        NSLog(@"[PangoAttribute][Warning]Create font attribute with 0 font size, set to 12");
        size = 12;
    }
    //    CFStringRef f = CGFontCopyPostScriptName(obj);
    PangoFontDescription *desc = pango_font_description_new();
    pango_font_description_set_family(desc, family);
    pango_font_description_set_absolute_size(desc, size*PANGO_SCALE);
    pango_font_description_set_style(desc, PANGO_STYLE_NORMAL);
    PangoAttribute *attr =pango_attr_font_desc_new(desc);
    return attr;
}

- (PangoAttribute *)createPangoForegroundColorAttributeFromNSAttributedValue:(id)obj
{
    CGColorRef color;
    Class uiColorClass = NSClassFromString(@"UIColor");
    if ([obj isKindOfClass:uiColorClass]) {
        color = (CGColorRef)[obj CGColor];
    } else {
        color = obj;
    }
    const CGFloat *rgba = CGColorGetComponents(color);
    PangoAttribute *attr = pango_attr_foreground_new(rgba[0] * 65535.,
                                                     rgba[1] * 65535.,
                                                     rgba[2] * 65535.);
    return attr;
}

- (void)fillAttributeList:(PangoAttrList *)list withAttributedString:(NSAttributedString *)attributedString
{
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        [attrs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            PangoAttribute *patt = NULL;
            if ([key isEqualToString:(NSString *)kCTFontAttributeName]) {
                patt = [self createPangoFontAttributeFromNSAttributedValue:obj];
            } else if ([key isEqualToString:(NSString *)kCTForegroundColorFromContextAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTKernAttributeName]) {
                patt = pango_attr_letter_spacing_new([obj intValue]);
            } else if ([key isEqualToString:(NSString *)kCTLigatureAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTForegroundColorAttributeName]) {
                patt = [self createPangoForegroundColorAttributeFromNSAttributedValue:obj];
            } else if ([key isEqualToString:(NSString *)kCTParagraphStyleAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTStrokeWidthAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTStrokeColorAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTUnderlineStyleAttributeName]) {
                CTUnderlineStyle style = [obj intValue];
                PangoUnderline underline = PANGO_UNDERLINE_NONE;
                switch (style) {
                    case kCTUnderlineStyleNone: underline = PANGO_UNDERLINE_NONE; break;
                    case kCTUnderlineStyleSingle: underline = PANGO_UNDERLINE_SINGLE; break;
                    case kCTUnderlineStyleThick: underline = PANGO_UNDERLINE_ERROR; break; // FIXME: RIGHT?
                    case kCTUnderlineStyleDouble:  underline = PANGO_UNDERLINE_DOUBLE;break;
                }
                patt = pango_attr_underline_new(underline);
            } else if ([key isEqualToString:(NSString *)kCTSuperscriptAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTUnderlineColorAttributeName]) {
                const CGFloat *rgba = CGColorGetComponents(obj);
                patt = pango_attr_underline_color_new(rgba[0] * 65535.,
                                                      rgba[1] * 65535.,
                                                      rgba[2] * 65535.);
            } else if ([key isEqualToString:(NSString *)kCTVerticalFormsAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTGlyphInfoAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTCharacterShapeAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTLanguageAttributeName]) {
                const char * l = [obj UTF8String];
                PangoLanguage *language = pango_language_from_string(l);
                patt = pango_attr_language_new(language);
            } else if ([key isEqualToString:(NSString *)kCTRunDelegateAttributeName]) {
                // shape
                CTRunDelegateRef delegate = obj;
                // need access delegate's callbacks
                
                PangoRectangle logical_rect;
                logical_rect.width = 20;
                logical_rect.height = 20;
                logical_rect.x = 0;
                logical_rect.y = 0;
                PangoRectangle ink_rect = logical_rect;
                
                patt = pango_attr_shape_new(&ink_rect, &logical_rect);
            } else if ([key isEqualToString:(NSString *)kCTBaselineClassAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTBaselineInfoAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTBaselineReferenceInfoAttributeName]) {
            } else if ([key isEqualToString:(NSString *)kCTWritingDirectionAttributeName]) {
            }
            
            if (patt != NULL) {
                patt->start_index = range.location;
                patt->end_index = NSMaxRange(range);
                NSLog(@"[PangoAttribute]insert attribute: %@, range:%@",key,NSStringFromRange(range));
                pango_attr_list_insert(list, patt);
            }
        }];
    }];
}

@end

void pango_layout_set_attributedString(PangoLayout *layout,
                                       NSAttributedString *as)
{
    pango_layout_set_attributedString_with_options(layout, as, nil);
}

void pango_layout_set_attributedString_with_options(PangoLayout *layout,
                                                    NSAttributedString *as,
                                                    NSDictionary *options)
{
    [as configurePangoLayout:layout options:options];
}
