//
//  PKCS7Container.m
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

#import "PKCS7Container.h"

#import <openssl/objects.h>
#import <openssl/pkcs7.h>
#import <openssl/x509.h>

NS_ASSUME_NONNULL_BEGIN

static BOOL IsValid(PKCS7 * _Nullable pkcs7);
static X509_STORE *CreateStoreWithCertificate(NSData *data);
static X509 *CreateCertificateWithData(NSData *data);

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

- (BOOL)isSignatureValidWithRootCertificate:(NSData *)certificate {
    X509_STORE *store = CreateStoreWithCertificate(certificate);
    BOOL result = PKCS7_verify(self.pkcs7, NULL, store, NULL, NULL, 0) == 1;
    X509_STORE_free(store);
    return result;
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

static X509_STORE * _Nonnull CreateStoreWithCertificate(NSData * _Nonnull data) {
    NSCParameterAssert(data);
    X509 *certificate = CreateCertificateWithData(data);
    X509_STORE *store = X509_STORE_new();
    assert(store);
    X509_STORE_add_cert(store, certificate);
    X509_free(certificate);
    return store;
}

static X509 * _Nonnull CreateCertificateWithData(NSData * _Nonnull data) {
    NSCParameterAssert(data);
    const unsigned char *bytes = data.bytes;
    X509 *result = d2i_X509(NULL, &bytes, data.length);
    assert(result);
    return result;
}
