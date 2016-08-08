//
//  ReceiptChecksum.m
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

#import "ReceiptChecksum.h"

#import <CommonCrypto/CommonDigest.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReceiptChecksum ()

@property(nonatomic, readonly) NSData *concatenated;

@end

NS_ASSUME_NONNULL_END

@implementation ReceiptChecksum

- (instancetype)initWithGUID:(NSData *)guid opaque:(NSData *)opaque identifier:(NSData *)identifier {
    NSParameterAssert(guid);
    NSParameterAssert(opaque);
    NSParameterAssert(identifier);
    if ((self = [super init])) {
        NSMutableData *data = [NSMutableData data];
        [data appendData:guid];
        [data appendData:opaque];
        [data appendData:identifier];
        _concatenated = data;
    }
    return self;
}

- (nonnull NSData *)dataValue {
    NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.concatenated.bytes, (CC_LONG)self.concatenated.length, result.mutableBytes);
    return result;
}

@end
