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

@property(nonatomic, readonly, copy) NSString *SIPAddress;
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *user;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *host;
@property(nonatomic, assign) NSInteger port;
@property(nonatomic, copy) NSString *userParameter;
@property(nonatomic, copy) NSString *methodParameter;
@property(nonatomic, copy) NSString *transportParameter;
@property(nonatomic, assign) NSInteger TTLParameter;
@property(nonatomic, assign) NSInteger looseRoutingParameter;
@property(nonatomic, copy) NSString *maddrParameter;

+ (id)SIPURIWithUser:(NSString *)aUser
                host:(NSString *)aHost
         displayName:(NSString *)aDisplayName;

+ (id)SIPURIWithString:(NSString *)SIPURIString;

// Designated initializer.
- (id)initWithUser:(NSString *)aUser
              host:(NSString *)aHost
       displayName:(NSString *)aDisplayName;

- (id)initWithString:(NSString *)SIPURIString;

@end
