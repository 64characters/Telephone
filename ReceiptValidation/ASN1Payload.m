//
//  ASN1Payload.m
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

#import "ASN1Payload.h"

#import <Payload.h>

#import "ReceiptValidation-Swift.h"

static Payload_t * _Nullable CreatePayloadWithData(NSData * _Nonnull data);

@implementation ASN1Payload

- (nullable instancetype)initWithData:(nonnull NSData *)data {
    NSParameterAssert(data);
    Payload_t *payload = CreatePayloadWithData(data);
    if (!payload) {
        return nil;
    }
    if ((self = [super init])) {
        NSMutableArray *attributes = [NSMutableArray array];
        for (NSInteger i = 0; i < payload->list.count; i++) {
            ReceiptAttribute_t *attribute = payload->list.array[i];
            NSData *value = [NSData dataWithBytes:attribute->value.buf length:attribute->value.size];
            [attributes addObject:[[ASN1PayloadAttribute alloc] initWithType:attribute->type value:value]];
        }
        _attributes = [attributes copy];
    }
    asn_DEF_Payload.free_struct(&asn_DEF_Payload, payload, 0);
    return self;
}

@end

static Payload_t * _Nullable CreatePayloadWithData(NSData * _Nonnull data) {
    NSCParameterAssert(data);
    Payload_t *payload = NULL;
    asn_dec_rval_t rval = asn_DEF_Payload.ber_decoder(0, &asn_DEF_Payload, (void **)&payload, data.bytes, data.length, 0);
    if (rval.code == RC_OK) {
        return payload;
    } else {
        asn_DEF_Payload.free_struct(&asn_DEF_Payload, payload, 0);
        return NULL;
    }
}
