//
//  CTRunDelegate.h
//  CoreText
//
//  Created by Chen Yonghui on 1/10/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#ifndef OPAL_CTRUNDELEGATE_h
#define OPAL_CTRUNDELEGATE_h

#include <CoreGraphics/CGBase.h>
#include <CoreText/CTRun.h>

#if defined(__cplusplus)
extern "C" {
#endif

@class CTRunDelegate;
typedef CTRunDelegate* CTRunDelegateRef;

CFTypeID CTRunDelegateGetTypeID( void );

typedef void (*CTRunDelegateDeallocateCallback) (
void* refCon );

typedef CGFloat (*CTRunDelegateGetAscentCallback) (
                                                   void* refCon );
typedef CGFloat (*CTRunDelegateGetDescentCallback) (
                                                    void* refCon );
typedef CGFloat (*CTRunDelegateGetWidthCallback) (
                                                  void* refCon );

typedef struct
{
	CFIndex							version;
	CTRunDelegateDeallocateCallback	dealloc;
	CTRunDelegateGetAscentCallback	getAscent;
	CTRunDelegateGetDescentCallback	getDescent;
	CTRunDelegateGetWidthCallback	getWidth;
} CTRunDelegateCallbacks;

enum {
	kCTRunDelegateVersion1 = 1,
	kCTRunDelegateCurrentVersion = kCTRunDelegateVersion1
};

CTRunDelegateRef CTRunDelegateCreate(
                                     const CTRunDelegateCallbacks* callbacks,
                                     void* refCon );
void* CTRunDelegateGetRefCon(
                             CTRunDelegateRef runDelegate );


#if defined(__cplusplus)
}
#endif

#endif

