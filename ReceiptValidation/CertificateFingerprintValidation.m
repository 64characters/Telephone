//
//  CertificateFingerprintValidation.m
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

#import "CertificateFingerprintValidation.h"

#import <CommonCrypto/CommonDigest.h>

static BOOL IsFingerprintValid(NSURL *certificate, NSData *sha256);

static const unsigned char fingerprintBytes[CC_SHA256_DIGEST_LENGTH] = {
    0xb0, 0xb1, 0x73, 0x0e, 0xcb, 0xc7, 0xff, 0x45,
    0x05, 0x14, 0x2c, 0x49, 0xf1, 0x29, 0x5e, 0x6e,
    0xda, 0x6b, 0xca, 0xed, 0x7e, 0x2c, 0x68, 0xc5,
    0xbe, 0x91, 0xb5, 0xa1, 0x10, 0x01, 0xf0, 0x24
};

NS_ASSUME_NONNULL_BEGIN

@interface CertificateFingerprintValidation ()

@property(nonatomic, readonly) id<ReceiptValidation> origin;
@property(nonatomic, readonly) NSURL *certificate;
@property(nonatomic, readonly) NSData *fingerprint;

@end

NS_ASSUME_NONNULL_END

@implementation CertificateFingerprintValidation

- (instancetype)initWithOrigin:(id<ReceiptValidation>)origin certificate:(NSURL *)certificate {
    if ((self = [super init])) {
        _origin = origin;
        _certificate = certificate;
        _fingerprint = [NSData dataWithBytes:fingerprintBytes length:CC_SHA256_DIGEST_LENGTH];
    }
    return self;
}

#pragma mark - ReceiptValidation

- (void)validateReceipt:(NSData * _Nonnull)receipt completion:(void (^ _Nonnull)(Result))completion {
    if (IsFingerprintValid(self.certificate, self.fingerprint)) {
        [self.origin validateReceipt:receipt completion:completion];
    } else {
        completion(ResultReceiptIsInvalid);
    }
}

@end

static BOOL IsFingerprintValid(NSURL *certificate, NSData *fingerprint) {
    NSData *data = [NSData dataWithContentsOfURL:certificate];
    NSMutableData *digest = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest.mutableBytes);
    return [digest isEqualToData:fingerprint];
}
