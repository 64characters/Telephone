//
//  PKCS7SignatureValidation.m
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

#import "PKCS7SignatureValidation.h"

#import <openssl/x509.h>

static BOOL IsSignatureValid(NSData *data, NSURL *certificateURL);
static BOOL IsSignatureValidWithStore(NSData *data, X509_STORE *store);
static X509_STORE *CreateStoreWithCertificateAtURL(NSURL *url);
static X509 *CreateCertificateWithContentsOfURL(NSURL *url);
static PKCS7 *CreatePKCS7WithData(NSData *data);

NS_ASSUME_NONNULL_BEGIN

@interface PKCS7SignatureValidation ()

@property(nonatomic, readonly) id<ReceiptValidation> origin;
@property(nonatomic, readonly) NSURL *certificate;

@end

NS_ASSUME_NONNULL_END

@implementation PKCS7SignatureValidation

- (instancetype)initWithOrigin:(id<ReceiptValidation>)origin certificate:(NSURL *)certificate {
    if ((self = [super init])) {
        _origin = origin;
        _certificate = certificate;
    }
    return self;
}

#pragma mark - ReceiptValidation

- (void)validateReceipt:(NSData * _Nonnull)receipt completion:(void (^ _Nonnull)(enum Result))completion {
    if (IsSignatureValid(receipt, self.certificate)) {
        [self.origin validateReceipt:receipt completion:completion];
    } else {
        completion(ResultReceiptIsInvalid);
    }
}

@end

static BOOL IsSignatureValid(NSData *data, NSURL *certificateURL) {
    OpenSSL_add_all_digests();
    X509_STORE *store = CreateStoreWithCertificateAtURL(certificateURL);
    BOOL result = IsSignatureValidWithStore(data, store);
    X509_STORE_free(store);
    EVP_cleanup();
    return result;
}

static BOOL IsSignatureValidWithStore(NSData *data, X509_STORE *store) {
    PKCS7 *pkcs7 = CreatePKCS7WithData(data);
    BOOL result = PKCS7_verify(pkcs7, NULL, store, NULL, NULL, 0) == 1;
    PKCS7_free(pkcs7);
    return result;
}

static X509_STORE *CreateStoreWithCertificateAtURL(NSURL *url) {
    X509 *certificate = CreateCertificateWithContentsOfURL(url);
    X509_STORE *store = X509_STORE_new();
    X509_STORE_add_cert(store, certificate);
    X509_free(certificate);
    return store;
}

static X509 *CreateCertificateWithContentsOfURL(NSURL *url) {
    NSData *data = [NSData dataWithContentsOfURL:url];
    const unsigned char *bytes = data.bytes;
    return d2i_X509(NULL, &bytes, data.length);
}

static PKCS7 *CreatePKCS7WithData(NSData *data) {
    const unsigned char *bytes = data.bytes;
    return d2i_PKCS7(NULL, &bytes, data.length);
}
