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

#import <openssl/pkcs7.h>

@implementation PKCS7Container

- (nullable instancetype)initWithData:(nonnull NSData *)data {
    NSParameterAssert(data);
    const unsigned char *bytes = data.bytes;
    PKCS7 *pkcs7 = d2i_PKCS7(NULL, &bytes, data.length);
    if (!pkcs7) {
        return nil;
    }
    if ((self = [super init])) {
        ASN1_OCTET_STRING *octets = pkcs7->d.sign->contents->d.data;
        _content = [NSData dataWithBytes:octets->data length:octets->length];
    }
    PKCS7_free(pkcs7);
    return self;
}

@end
