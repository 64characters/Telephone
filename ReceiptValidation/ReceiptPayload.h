//
//  Receipt.h
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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface ReceiptPayload : NSObject

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) NSData *identifierData;
@property(nonatomic, readonly) NSString *version;
@property(nonatomic, readonly) NSData *opaque;
@property(nonatomic, readonly) NSData *checksum;

- (nullable instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
