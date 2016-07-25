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
#define DRSProduction @"https://dash-replenishment-service-na.amazon.com"
#define DRSProductionWebContent @"https://drs-web.amazon.com"

@interface CPAmazonAPI : AFHTTPSessionManager


- (NSURLSessionDataTask *) sendAuthCode : (NSString *)authCode
                             grant_type : (NSString *)grant_type
                               clientId : (NSString *)clientId
                           redirect_uri : (NSString *)redirect_uri
                          code_verifier : (NSString *)code_verifier
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) sendRefreshToken : (NSString *)refreshToken
                                 grant_type : (NSString *)grant_type
                                  client_id : (NSString *)clientId
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) replenishAPI : (NSString *)authorization
                             acceptType : (NSString *)acceptType
                            typeVersion : typeVersion
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure;


@end
