//
//  AKKeychain.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 29.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AKKeychain : NSObject {

}

+ (NSString *)passwordForServiceName:(NSString *)serviceName
						 accountName:(NSString *)accountName;

+ (BOOL)addItemWithServiceName:(NSString *)serviceName
				   accountName:(NSString *)accountName
					  password:(NSString *)password;

@end
