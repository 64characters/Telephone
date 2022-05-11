//
//  NameServers.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import "NameServers.h"

@import SystemConfiguration;

static NSString * const kDynamicStoreDNSSettings = @"State:/Network/Global/DNS";
static void NameServersDidChange(SCDynamicStoreRef store, CFArrayRef keys, void *info);

@interface NameServers ()

@property(nonatomic, readonly) SCDynamicStoreRef store;
@property(nonatomic, readonly) id <NameServersChangeEventTarget> target;

@end

@implementation NameServers

- (instancetype)initWithBundle:(NSBundle *)bundle target:(id <NameServersChangeEventTarget>)target {
    if ((self = [super init])) {
        SCDynamicStoreContext context = {0, (__bridge void * _Nullable)(self), NULL, NULL, NULL};
        _store = SCDynamicStoreCreate(kCFAllocatorDefault,
                                      (__bridge CFStringRef)bundle.infoDictionary[@"CFBundleName"],
                                      &NameServersDidChange,
                                      &context);
        _target = target;
        SCDynamicStoreSetNotificationKeys(_store, (__bridge CFArrayRef)@[kDynamicStoreDNSSettings], NULL);
        CFRunLoopSourceRef source = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, _store, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopDefaultMode);
        CFRelease(source);
    }
    return self;
}

- (void)dealloc {
    CFRelease(_store);
}

- (NSArray<NSString *> *)all {
    NSArray *result;
    CFPropertyListRef settings = SCDynamicStoreCopyValue(self.store, (__bridge CFStringRef)kDynamicStoreDNSSettings);
    if (settings) {
        result = ((__bridge NSDictionary *)settings)[@"ServerAddresses"];
        CFRelease(settings);
    } else {
        result = @[];
    }
    return result;
}

- (void)notifyTarget {
    [self.target nameServersDidChange:self];
}

@end

static void NameServersDidChange(SCDynamicStoreRef store, CFArrayRef keys, void *info) {
    [(__bridge NameServers *)info notifyTarget];
}
