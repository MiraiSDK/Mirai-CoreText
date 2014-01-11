/** <title>CTStringAttribute</title>

   <abstract>C Interface to text layout library</abstract>

   Copyright <copy>(C) 2010 Free Software Foundation, Inc.</copy>

   Author: Eric Wasylishen
   Date: Aug 2010

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
   */

#include <CoreText/CTStringAttributes.h>
/* Constants */
#if ANDROID
const CFStringRef kCTFontAttributeName = @"NSFont";
const CFStringRef kCTForegroundColorFromContextAttributeName = @"CTForegroundColorFromContext";
const CFStringRef kCTKernAttributeName = @"NSKern";
const CFStringRef kCTLigatureAttributeName = @"NSLigature";
const CFStringRef kCTForegroundColorAttributeName = @"CTForegroundColor";
const CFStringRef kCTParagraphStyleAttributeName = @"NSParagraphStyle";
const CFStringRef kCTStrokeWidthAttributeName = @"NSStrokeWidth";
const CFStringRef kCTStrokeColorAttributeName = @"CTStrokeColor";
const CFStringRef kCTUnderlineStyleAttributeName = @"NSUnderline";
const CFStringRef kCTSuperscriptAttributeName = @"NSSuperScript";
const CFStringRef kCTUnderlineColorAttributeName = @"CTUnderlineColor";
const CFStringRef kCTVerticalFormsAttributeName = @"CTVerticalForms";
const CFStringRef kCTGlyphInfoAttributeName = @"NSGlyphInfo";
const CFStringRef kCTCharacterShapeAttributeName = @"NSCharacterShape";

const CFStringRef kCTLanguageAttributeName = @"NSLanguage";
const CFStringRef kCTRunDelegateAttributeName = @"CTRunDelegate";
const CFStringRef kCTBaselineClassAttributeName = @"CTBaselineClass";
const CFStringRef kCTBaselineInfoAttributeName = @"CTBaselineInfo";
const CFStringRef kCTBaselineReferenceInfoAttributeName = @"CTBaselineReferenceInfo";
const CFStringRef kCTWritingDirectionAttributeName = @"NSWritingDirection";

#else
const CFStringRef kCTFontAttributeName = CFSTR("NSFont");
const CFStringRef kCTForegroundColorFromContextAttributeName = CFSTR("CTForegroundColorFromContext");
const CFStringRef kCTKernAttributeName = CFSTR("NSKern");
const CFStringRef kCTLigatureAttributeName = CFSTR("NSLigature");
const CFStringRef kCTForegroundColorAttributeName = CFSTR("CTForegroundColor");
const CFStringRef kCTParagraphStyleAttributeName = CFSTR("NSParagraphStyle");
const CFStringRef kCTStrokeWidthAttributeName = CFSTR("NSStrokeWidth");
const CFStringRef kCTStrokeColorAttributeName = CFSTR("CTStrokeColor");
const CFStringRef kCTUnderlineStyleAttributeName = CFSTR("NSUnderline");
const CFStringRef kCTSuperscriptAttributeName = CFSTR("NSSuperScript");
const CFStringRef kCTUnderlineColorAttributeName = CFSTR("CTUnderlineColor");
const CFStringRef kCTVerticalFormsAttributeName = CFSTR("CTVerticalForms");
const CFStringRef kCTGlyphInfoAttributeName = CFSTR("NSGlyphInfo");
const CFStringRef kCTCharacterShapeAttributeName = CFSTR("NSCharacterShape");

const CFStringRef kCTLanguageAttributeName = CFSTR("NSLanguage");
const CFStringRef kCTRunDelegateAttributeName = CFSTR("CTRunDelegate");
const CFStringRef kCTBaselineClassAttributeName = CFSTR("CTBaselineClass");
const CFStringRef kCTBaselineInfoAttributeName = CFSTR("CTBaselineInfo");
const CFStringRef kCTBaselineReferenceInfoAttributeName = CFSTR("CTBaselineReferenceInfo");
const CFStringRef kCTWritingDirectionAttributeName = CFSTR("NSWritingDirection");

#endif
