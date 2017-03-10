//
//  AKSIPURI.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

#import <Foundation/Foundation.h>


// A class representing SIP URI.
@interface AKSIPURI : NSObject <NSCopying>

// SIP address in the form |user@host| or |host|.
@property(nonatomic, readonly, copy) NSString *SIPAddress;

// The receiver's display-name part.
@property(nonatomic, copy) NSString *displayName;

// The receiver's user part.
@property(nonatomic, copy) NSString *user;

// The receiver's password part.
@property(nonatomic, copy) NSString *password;

// The receiver's host part. Must not be nil.
@property(nonatomic, copy) NSString *host;

// The receiver's port part.
@property(nonatomic, assign) NSInteger port;

// The receiver's user parameter.
@property(nonatomic, copy) NSString *userParameter;

// The receiver's method parameter.
@property(nonatomic, copy) NSString *methodParameter;

// The receiver's transport parameter.
@property(nonatomic, copy) NSString *transportParameter;

// The receiver's TTL parameter.
@property(nonatomic, assign) NSInteger TTLParameter;

// The receiver's loose routing parameter.
@property(nonatomic, assign) NSInteger looseRoutingParameter;

// The receiver's maddr parameter.
@property(nonatomic, copy) NSString *maddrParameter;

// Creates and returns AKSIPURI object initialized with a specified user, host, and display name.
+ (instancetype)SIPURIWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName;

// Creates and returns AKSIPURI object initialized with a provided string.
+ (instancetype)SIPURIWithString:(NSString *)SIPURIString;

// Designated initializer.
// Initializes a AKSIPURI object with a specified user, host, and display name.
- (instancetype)initWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName;

// Initializes a AKSIPURI object with a provided string.
- (instancetype)initWithString:(NSString *)SIPURIString;

@end
