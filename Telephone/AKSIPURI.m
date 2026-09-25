//
//  AKSIPURI.m
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

#import "AKSIPURI.h"

@import UseCases;

@implementation AKSIPURI

- (NSString *)SIPAddress {
    return [[SIPAddress alloc] initWithUser:self.user host:self.host].stringValue;
}


#pragma mark -

+ (instancetype)SIPURIWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName {
    return [[self alloc] initWithUser:user host:host displayName:displayName];
}

+ (nullable instancetype)SIPURIWithString:(NSString *)SIPURIString {
    return [[self alloc] initWithString:SIPURIString];
}

- (instancetype)initWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName port:(NSInteger)port {
    NSParameterAssert(user);
    NSParameterAssert(host);
    NSParameterAssert(displayName);
    self = [super init];
    if ((self != nil)) {
        _user = [user copy];
        _host = [host copy];
        _displayName = [displayName copy];
    }
    return self;
}

- (instancetype)initWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName {
    return [self initWithUser:user host:host displayName:displayName port:0];
}

- (instancetype)init {
    return [self initWithUser:@"" host:@"" displayName:@""];
}

- (nullable instancetype)initWithString:(NSString *)SIPURIString {
    URI *uri = [[URI alloc] initWithString:SIPURIString];
    if (uri) {
        return [self initWithUser:uri.user host:uri.host displayName:uri.displayName];
    } else {
        return nil;
    }
}

- (NSString *)description {
    NSString *port = self.port > 0 ? @(self.port).stringValue : @"";
    return [[URI alloc] initWithUser:self.user
                             address:[[ServiceAddress alloc] initWithHost:self.host port:port]
                         displayName:self.displayName
                           transport:TransportUDP].stringValue;
}


#pragma mark -
#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[AKSIPURI allocWithZone:zone] initWithUser:self.user
                                                  host:self.host
                                           displayName:self.displayName
                                                  port:self.port];
}


#pragma mark -
#pragma mark Equality

- (BOOL)isEqualToURI:(nullable AKSIPURI *)uri {
    if (uri == nil) {
        return NO;
    }
    if (self == uri) {
        return YES;
    }
    return [self.user isEqualToString:uri.user] &&
           [self.host isEqualToString:uri.host] &&
           [self.displayName isEqualToString:uri.displayName] &&
           self.port == uri.port;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AKSIPURI class]]) {
        return [self isEqualToURI:(AKSIPURI *)object];
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return self.user.hash ^ self.host.hash ^ self.displayName.hash ^ self.port;
}

@end
