//
//  CPReplenishDashUtil.h
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

@interface CPReplenishDashUtil : NSObject

+ (NSArray *)appRequestScopes;
+ (NSDictionary *)appRequestScopeOptions;

@end
