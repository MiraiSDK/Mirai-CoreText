
#import "CTFontManager.h"

CFArrayRef CTFontManagerCopyAvailablePostScriptNames()
{
    return nil;
}

CFArrayRef CTFontManagerCopyAvailableFontFamilyNames()
{
    return nil;
}

CFArrayRef CTFontManagerCopyAvailableFontURLs()
{
    return nil;
}

CFComparisonResult CTFontManagerCompareFontFamilyNames(
                                                       const void *a,
                                                       const void *b,
                                                       void *info
                                                       )
{
    return kCFCompareEqualTo;
}

CFArrayRef CTFontManagerCreateFontDescriptorsFromURL(CFURLRef fileURL)
{
    return nil;
}

bool CTFontManagerRegisterFontsForURL(
                                      CFURLRef fontURL,
                                      CTFontManagerScope scope,
                                      CFErrorRef *errors
                                      )
{
    return false;
}

bool CTFontManagerUnregisterFontsForURL(
                                        CFURLRef fontURL,
                                        CTFontManagerScope scope,
                                        CFErrorRef *errors
                                        )
{
    return false;
}

bool CTFontManagerRegisterFontsForURLs(
                                       CFArrayRef fontURLs,
                                       CTFontManagerScope scope,
                                       CFArrayRef *errors
                                       )
{
    return false;
}

bool CTFontManagerUnregisterFontsForURLs(
                                         CFArrayRef fontURLs,
                                         CTFontManagerScope scope,
                                         CFArrayRef *errors
                                         )
{
    return false;
}

void CTFontManagerEnableFontDescriptors(
                                        CFArrayRef descriptors,
                                        bool enable
                                        )
{
    
}

CTFontManagerScope CTFontManagerGetScopeForURL(CFURLRef fontURL)
{
    return kCTFontManagerScopeNone;
}

bool CTFontManagerIsSupportedFont(CFURLRef fontURL)
{
    return false;
}

#if defined(__BLOCKS__)
CFRunLoopSourceRef CTFontManagerCreateFontRequestRunLoopSource(
                                                               CFIndex sourceOrder, 
                                                               CFArrayRef (^createMatchesCallback)(CFDictionaryRef requestAttributes, pid_t requestingProcess)
                                                               )
{
    return NULL;
}
#endif

void CTFontManagerSetAutoActivationSetting(
                                           CFStringRef bundleIdentifier,
                                           CTFontManagerAutoActivationSetting setting
                                           )
{
    
}

CTFontManagerAutoActivationSetting CTFontManagerGetAutoActivationSetting(
                                                                         CFStringRef bundleIdentifier
                                                                         )
{
    return kCTFontManagerAutoActivationDefault;
}

bool CTFontManagerRegisterGraphicsFont(
                                       CGFontRef               font,
                                       CFErrorRef *            error )
{
    return false;
}

bool CTFontManagerUnregisterGraphicsFont(
                                         CGFontRef               font,
                                         CFErrorRef *            error )
{
    return false;
}

