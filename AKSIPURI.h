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


@interface AKSIPURI : NSObject <NSCopying> {
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

@property(nonatomic, readonly, copy) NSString *SIPAddress;
@property(readwrite, copy) NSString *displayName;
@property(readwrite, copy) NSString *user;
@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *host;
@property(readwrite, assign) NSInteger port;
@property(readwrite, copy) NSString *userParameter;
@property(readwrite, copy) NSString *methodParameter;
@property(readwrite, copy) NSString *transportParameter;
@property(readwrite, assign) NSInteger TTLParameter;
@property(readwrite, assign) NSInteger looseRoutingParameter;
@property(readwrite, copy) NSString *maddrParameter;

+ (id)SIPURIWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName;
+ (id)SIPURIWithString:(NSString *)SIPURIString;

- (id)initWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName;	// Designated initializer.
- (id)initWithString:(NSString *)SIPURIString;

@end
