#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MDNSDelegate.h"
#import "MDNSPlugin.h"
#import "NSNetService+Util.h"

FOUNDATION_EXPORT double mdns_pluginVersionNumber;
FOUNDATION_EXPORT const unsigned char mdns_pluginVersionString[];

