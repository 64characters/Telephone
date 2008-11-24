//
//  AKSIPURI.h
//  Telephone
//
//  Copyright (c) 2008 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>


@interface AKSIPURI : NSObject {
@private
	NSString *displayName;
	NSString *user;
	NSString *password;
	NSString *host;
	NSInteger port;
	NSString *userParameter;
	NSString *methodParameter;
	NSString *transportParameter;
	NSInteger TTLParameter;
	NSInteger looseRoutingParameter;
	NSString *maddrParameter;
}

@property(readonly, copy) NSString *SIPAddress;
@property(readonly, copy) NSString *displayName;
@property(readonly, copy) NSString *user;
@property(readonly, copy) NSString *password;
@property(readonly, copy) NSString *host;
@property(readonly, assign) NSInteger port;
@property(readonly, copy) NSString *userParameter;
@property(readonly, copy) NSString *methodParameter;
@property(readonly, copy) NSString *transportParameter;
@property(readonly, assign) NSInteger TTLParameter;
@property(readonly, assign) NSInteger looseRoutingParameter;
@property(readonly, copy) NSString *maddrParameter;

- (id)initWithString:(NSString *)SIPURIString;

+ (id)SIPURIWithString:(NSString *)SIPURIString;

@end
