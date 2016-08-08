//
//  Receipt.m
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

#import "ReceiptPayload.h"

#import <openssl/pkcs7.h>
#import <Payload.h>

static const NSInteger kIdentifier = 2;
static const NSInteger kVersion = 3;
static const NSInteger kOpaque = 4;
static const NSInteger kChecksum = 5;

static const uint8_t ANS1TypeIndex = 0;
static const uint8_t ASN1LengthIndex = 1;
static const uint8_t ASN1ContentIndex = 2;
static const uint8_t ASN1UTF8String = 0x0c;

static PKCS7 * _Nonnull CreatePKCS7WithData(NSData * _Nonnull data);
static Payload_t * _Nullable CreatePayloadWithOctetString(ASN1_OCTET_STRING * _Nonnull octets);
static NSString * _Nonnull StringWithOctets(OCTET_STRING_t *octets);

@implementation ReceiptPayload

- (nullable instancetype)initWithData:(nonnull NSData *)data {
    NSParameterAssert(data);

    PKCS7 *pkcs7 = CreatePKCS7WithData(data);
    assert(pkcs7);
    Payload_t *payload = CreatePayloadWithOctetString(pkcs7->d.sign->contents->d.data);
    PKCS7_free(pkcs7);
    if (!payload) {
        return nil;
    }
    if ((self = [super init])) {
        OCTET_STRING_t *identifier = NULL;
        OCTET_STRING_t *version = NULL;
        OCTET_STRING_t *opaque = NULL;
        OCTET_STRING_t *checksum = NULL;
        for (NSInteger i = 0; i < payload->list.count; i++) {
            ReceiptAttribute_t *attribute = payload->list.array[i];
            switch (attribute->type) {
                case kIdentifier:
                    identifier = &attribute->value;
                    break;
                case kVersion:
                    version = &attribute->value;
                    break;
                case kOpaque:
                    opaque = &attribute->value;
                    break;
                case kChecksum:
                    checksum = &attribute->value;
                default:
                    break;
            }
        }
        assert(identifier);
        assert(version);
        assert(opaque);
        assert(checksum);
        _identifier = StringWithOctets(identifier);
        _identifierData = [NSData dataWithBytes:identifier->buf length:identifier->size];
        _version = StringWithOctets(version);
        _opaque = [NSData dataWithBytes:opaque->buf length:opaque->size];
        _checksum = [NSData dataWithBytes:checksum->buf length:checksum->size];
    }
    asn_DEF_Payload.free_struct(&asn_DEF_Payload, payload, 0);
    return self;
}

@end

static PKCS7 * _Nonnull CreatePKCS7WithData(NSData * _Nonnull data) {
    NSCParameterAssert(data);
    const unsigned char *bytes = data.bytes;
    return d2i_PKCS7(NULL, &bytes, data.length);
}

static Payload_t * _Nullable CreatePayloadWithOctetString(ASN1_OCTET_STRING * _Nonnull octets) {
    NSCParameterAssert(octets);
    Payload_t *payload = NULL;
    asn_dec_rval_t rval = asn_DEF_Payload.ber_decoder(0, &asn_DEF_Payload, (void **)&payload, octets->data, octets->length, 0);
    if (rval.code == RC_OK) {
        return payload;
    } else {
        asn_DEF_Payload.free_struct(&asn_DEF_Payload, payload, 0);
        return NULL;
    }
}

static NSString * _Nonnull StringWithOctets(OCTET_STRING_t *octets) {
    NSString *result = @"";
    if (octets->buf[ANS1TypeIndex] == ASN1UTF8String) {
        NSInteger length = octets->size - ASN1ContentIndex;
        assert(length == octets->buf[ASN1LengthIndex]);
        result = [[NSString alloc] initWithBytes:(octets->buf + ASN1ContentIndex) length:length encoding:NSUTF8StringEncoding];
    }
    return result;
}
