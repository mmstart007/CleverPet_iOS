//
//  CPAmazonAPI.h
//  CleverPet
//
//  Created by user on 7/5/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CPConfigManager.h"

#define CPBaseURL @"https://amazon.com"
#define DRSProduction @"https://dash-replenishment-service-na.amazon.com"
#define DRSProductionWebContent @"https://drs-web.amazon.com"


//NSString * const CPStageQAURL = @MACRO_VALUE(CP_API_BASE_URL);


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

- (NSURLSessionDataTask *) setDeviceIdInCP : (NSString *)device_id
                         cpuser_auth_token : (NSString *)cpuser_auth_token
                                   success : (void (^)(NSDictionary *result))success
                                   failure : (void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) setRefreshTokenInCP : (NSString *)refresh_token
                                     device_id : (NSString *)device_id
                                     client_id : (NSString *)client_id
                             cpuser_auth_token : (NSString *)cpuser_auth_token
                                       success : (void (^)(NSDictionary *result))success
                                       failure : (void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) setReplenishThresholdInCP : (NSString *)replenish_threshold
                                           device_id : (NSString *)device_id
                                   cpuser_auth_token : (NSString *)cpuser_auth_token
                                             success : (void (^)(NSDictionary *result))success
                                             failure : (void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) checkAmazonLogin : (NSString *)device_id
                          cpuser_auth_token : (NSString *)cpuser_auth_token
                                    success : (void (^)(NSDictionary *result, NSInteger responseCode))success
                                    failure : (void (^)(NSError *error))failure;




@end
