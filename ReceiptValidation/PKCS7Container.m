//
//  PKCS7Container.m
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

#import "PKCS7Container.h"

#import <openssl/objects.h>
#import <openssl/pkcs7.h>

static BOOL IsValid(PKCS7 * _Nullable pkcs7);

NS_ASSUME_NONNULL_BEGIN

@interface PKCS7Container ()

@property(nonatomic, readonly) PKCS7 *pkcs7;

@end

NS_ASSUME_NONNULL_END

@implementation PKCS7Container

- (nullable instancetype)initWithData:(nonnull NSData *)data {
    NSParameterAssert(data);
    if ((self = [super init])) {
        const unsigned char *bytes = data.bytes;
        _pkcs7 = d2i_PKCS7(NULL, &bytes, data.length);
        if (!IsValid(_pkcs7)) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    PKCS7_free(_pkcs7);
}

#pragma mark -

- (NSData *)content {
    ASN1_OCTET_STRING *octets = self.pkcs7->d.sign->contents->d.data;
    return [NSData dataWithBytes:octets->data length:octets->length];
}

@end

static BOOL IsValid(PKCS7 * _Nullable pkcs7) {
    if (pkcs7 == NULL) {
        return NO;
    }
    if (!PKCS7_type_is_signed(pkcs7)) {
        return NO;
    }
    if (!PKCS7_type_is_data(pkcs7->d.sign->contents)) {
        return NO;
    }
    return YES;
}
