//
//  PKCS7ContainerValidation.m
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

#import "PKCS7ContainerValidation.h"

#import <openssl/bio.h>
#import <openssl/objects.h>
#import <openssl/pkcs7.h>

static BOOL IsContainerValidWithData(NSData *data);
static BOOL IsContainerValidWithPKCS7(PKCS7 *pkcs7);
static PKCS7 *CreatePKCS7WithData(NSData *data);

@interface PKCS7ContainerValidation ()

@property(nonatomic, readonly) id<ReceiptValidation> origin;

@end

@implementation PKCS7ContainerValidation

- (instancetype)initWithOrigin:(id<ReceiptValidation>)origin {
    if ((self = [super init])) {
        _origin = origin;
    }
    return self;
}

#pragma mark - ReceiptValidation

- (void)validateReceipt:(NSData * _Nonnull)receipt completion:(void (^ _Nonnull)(enum Result))completion {
    if (IsContainerValidWithData(receipt)) {
        [self.origin validateReceipt:receipt completion:completion];
    } else {
        completion(ResultReceiptIsInvalid);
    }
}

@end

static BOOL IsContainerValidWithData(NSData *data) {
    PKCS7 *pkcs7 = CreatePKCS7WithData(data);
    BOOL result = IsContainerValidWithPKCS7(pkcs7);
    PKCS7_free(pkcs7);
    return result;
}

static BOOL IsContainerValidWithPKCS7(PKCS7 *pkcs7) {
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

static PKCS7 *CreatePKCS7WithData(NSData *data) {
    const unsigned char *bytes = data.bytes;
    return d2i_PKCS7(NULL, &bytes, data.length);
}
