//
//  AKSIPURI.h
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>


// A class representing SIP URI.
@interface AKSIPURI : NSObject <NSCopying> {
 @private
  NSString *displayName_;
  NSString *user_;
  NSString *password_;
  NSString *host_;
  NSInteger port_;
  NSString *userParameter_;
  NSString *methodParameter_;
  NSString *transportParameter_;
  NSInteger TTLParameter_;
  NSInteger looseRoutingParameter_;
  NSString *maddrParameter_;
}

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

// Creates and returns AKSIPURI object initialized with a specified user, host,
// and display name.
+ (id)SIPURIWithUser:(NSString *)aUser
                host:(NSString *)aHost
         displayName:(NSString *)aDisplayName;

// Creates and returns AKSIPURI object initialized with a provided string.
+ (id)SIPURIWithString:(NSString *)SIPURIString;

// Designated initializer.
// Initializes a AKSIPURI object with a specified user, host, and display name.
- (id)initWithUser:(NSString *)aUser
              host:(NSString *)aHost
       displayName:(NSString *)aDisplayName;

// Initializes a AKSIPURI object with a provided string.
- (id)initWithString:(NSString *)SIPURIString;

@end
