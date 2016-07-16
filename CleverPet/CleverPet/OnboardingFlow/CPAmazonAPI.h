//
//  CPAmazonAPI.h
//  CleverPet
//
//  Created by user on 7/5/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define CPBaseURL @"https://api.amazon.com"

@interface CPAmazonAPI : AFHTTPSessionManager


- (NSURLSessionDataTask *) sendAuthCode:(NSString *)authCode
                             grant_type:(NSString *)grant_type
                               clientId:(NSString *)clientId
                           redirect_uri:(NSString *)redirect_uri
                                success:(void (^)(NSDictionary *result))success
                                failure:(void (^)(NSError *error))failure;

@end
