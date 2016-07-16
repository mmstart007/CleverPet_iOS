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
                                success : (void (^)(NSDictionary *result))success
                                failure : (void (^)(NSError *error))failure;
{
    NSString *uri =  @"auth/o2/token";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"grant_type"    : grant_type,
                                       @"code"          : authCode,
                                       @"client_id"      : clientId,
                                       @"redirect_uri"  : redirect_uri,
                                       }];
    
/*    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:[NSString stringWithFormat:@"%@/%@", CPBaseURL, uri] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);

        id responseObject = [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:nil];
        
        NSLog(@"%@", responseObject);

    }];
*/
    
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
    NSLog(@"Request URL === %@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //blah blah
            }
        } else {
            NSLog(@"Error==== %@ \n\n , %@, \n\n %@", error, response, responseObject);
            
//            id responseObject = [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:nil];
//            
//            NSLog(@"%@", responseObject);

        }
    }] resume];
    
    return nil;
    
}


@end
