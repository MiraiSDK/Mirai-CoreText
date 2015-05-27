/** <title>CTParagraphStyle</title>

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

#include <CoreText/CTParagraphStyle.h>

@interface CTParagraphStyle : NSObject
@property (nonatomic, strong) NSDictionary *dict;
@end

@implementation CTParagraphStyle
- (instancetype)initWithSettings:(const CTParagraphStyleSetting *)settings settingCount:(CFIndex)settingCount
{
    self = [super init];
    if (self) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (CFIndex i = 0; i < settingCount; i++) {
            CTParagraphStyleSetting set = settings[i];
            NSUInteger length = (NSUInteger)set.valueSize;
            NSData *data = [NSData dataWithBytes:set.value length:length];
            dict[@(set.spec)] = data;
        }
        
        _dict = dict;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

/* Functions */

CFTypeID CTParagraphStyleGetTypeID()
{
  return (CFTypeID)[CTParagraphStyle class];
}

CTParagraphStyleRef CTParagraphStyleCreate(
	const CTParagraphStyleSetting* settings,
	CFIndex settingCount)
{
  return [[CTParagraphStyle alloc] initWithSettings:settings settingCount:settingCount];
}

CTParagraphStyleRef CTParagraphStyleCreateCopy(CTParagraphStyleRef paragraphStyle)
{
  return [paragraphStyle copy];
}

bool CTParagraphStyleGetValueForSpecifier(
	CTParagraphStyleRef paragraphStyle,
	CTParagraphStyleSpecifier spec,
	size_t valueBufferSize,
	void* valueBuffer)
{
    NSData  *value = paragraphStyle.dict[@(spec)];
    if (value) {
        [value getBytes:valueBuffer length:valueBufferSize];
        return true;
    }
  return false;
}

