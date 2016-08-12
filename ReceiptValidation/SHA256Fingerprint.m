//
//  SHA256Fingerprint.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#import "SHA256Fingerprint.h"

#import <CommonCrypto/CommonDigest.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHA256Fingerprint ()

@property(nonatomic, readonly) NSData *sha256;

@end

NS_ASSUME_NONNULL_END

@implementation SHA256Fingerprint

- (nonnull instancetype)initWithSHA256:(NSData *)sha256 {
    NSParameterAssert(sha256);
    if ((self = [super init])) {
        _sha256 = sha256;
    }
    return self;
}

- (nullable instancetype)initWithContentsOfURL:(nonnull NSURL *)url {
    NSParameterAssert(url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return nil;
    }
    NSMutableData *sha256 = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, sha256.mutableBytes);
    return [self initWithSHA256:sha256];
}

#pragma mark -

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![self isKindOfClass:[SHA256Fingerprint class]]) return NO;
    return [self isEqualToFingerprint:object];
}

- (BOOL)isEqualToFingerprint:(nullable SHA256Fingerprint *)fingerprint {
    if (!fingerprint) return NO;
    return [self.sha256 isEqualToData:fingerprint.sha256];
}

- (NSUInteger)hash {
    return [self.sha256 hash];
}

@end
