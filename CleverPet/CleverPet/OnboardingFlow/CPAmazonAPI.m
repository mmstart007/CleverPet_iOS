//
//  CPAmazonAPI.m
//  CleverPet
//
//  Created by user on 7/5/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPAmazonAPI.h"
	
@implementation CPAmazonAPI


+ (instancetype)manager
{
    return [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:CPBaseURL]];
}

- (NSURLSessionDataTask *) sendAuthCode : (NSString *)authCode
                             grant_type : (NSString *)grant_type
                               clientId : (NSString *)clientId
                           redirect_uri : (NSString *)redirect_uri
                          code_verifier : (NSString *)code_verifier
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure;
{
    NSString *uri =  @"auth/o2/token";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"grant_type"    : grant_type,
                                       @"code"          : authCode,
                                       @"client_id"     : clientId,
                                       @"redirect_uri"  : redirect_uri,
                                       @"code_verifier" : code_verifier,
                                       }];
    
    ///////
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/%@", CPBaseURL, uri] parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"Request URL === %@", req);
    
    [[manager dataTaskWithRequest:req
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
                    if (!error) {
                        //            NSLog(@"Reply JSON: %@", responseObject);
                        
                        success(responseObject);
                        
                    } else {
                        NSLog(@"Error==== %@ \n\n , %@, \n\n %@", error, response, responseObject);
                        failure(responseObject);
                    }
    }] resume];
    
    return nil;
    
}

- (NSURLSessionDataTask *)sendRefreshToken : (NSString *)refreshToken
                                grant_type : (NSString *)grant_type
                                 client_id : (NSString *)clientId
                                   success : (void (^)(NSDictionary *))success
                                   failure : (void (^)(NSError *))failure
{
    NSString *uri =  @"auth/o2/token";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"grant_type"    : grant_type,
                                       @"refresh_token" : refreshToken,
                                       @"client_id"     : clientId,
                                       }];
    ///////
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/%@", CPBaseURL, uri] parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"Request URL === %@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
//            NSLog(@"Reply JSON: %@", responseObject);
            success(responseObject);
        } else {
            NSLog(@"Error==== %@ \n\n , %@, \n\n %@", error, response, responseObject);
            failure(responseObject);
        }
    }] resume];
    
    return nil;
}

- (NSURLSessionDataTask *) replenishAPI : (NSString *)authorization
                             acceptType : (NSString *)acceptType
                            typeVersion : typeVersion
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure
{
    NSString *uri =  @"replenish/DryDogFoodKibble1";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"Authorization"         : authorization,
                                       @"x-amzn-accept-type"    : acceptType,
                                       @"x-amzn-type-version"   : typeVersion,
                                       }];
    NSLog(@"Params -----------, %@", params);
    
    ///////
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/%@", DRSProduction, uri] parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    //    NSLog(@"Request URL === %@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            success(responseObject);
        } else {
            NSLog(@"Error==== %@ \n\n , %@, \n\n %@", error, response, responseObject);
            failure(responseObject);
        }
    }] resume];
    
    return nil;
}

- (NSURLSessionDataTask *)setRefreshTokenInCP : (NSString *)refresh_token
                                    device_id : (NSString *)device_id
                            cpuser_auth_token : (NSString *)cpuser_auth_token
                                      success : (void (^)(NSDictionary *))success
                                      failure : (void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:@"registration/%@/refresh_token", device_id];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"device_ID"             : device_id,
                                       @"lwa_refresh_token"     : refresh_token,
                                       }];
    NSLog(@"Params -----------, %@", params);
    
    ///////
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/%@", CPProductionURL, url] parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:cpuser_auth_token forHTTPHeaderField:@"Authorization"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Request URL === %@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            success(responseObject);
        } else {
            NSLog(@"Error==== %@ \n\n , %@, \n\n %@", error, response, responseObject);
            failure(responseObject);
        }
    }] resume];

    return nil;
}



@end
