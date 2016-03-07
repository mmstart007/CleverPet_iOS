//
//  CPTileCommunicationManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-03.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCommunicationManager.h"
#import "CPAppEngineCommunicationManager.h"
#import <AFNetworking/AFNetworking.h>

// TODO: appropriate path for filter
NSString * const kTilesPath = @"users/tiles";
#define TILE_FILTER_PATH(filter) [NSString stringWithFormat:@"users/tiles/%@", filter]
#define TILE_PAGE_SIZE @(50)

@interface CPTileCommunicationManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation CPTileCommunicationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPTileCommunicationManager *s_sharedInstance;
    dispatch_once(&onceToken, ^{
        s_sharedInstance = [[CPTileCommunicationManager alloc] init];
    });
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Borrow the session manager from app engine communication manager so we don't need to manage auth in multiple places
        self.sessionManager = [[CPAppEngineCommunicationManager sharedInstance] getSessionManager];
    }
    return self;
}

- (ASYNC)refreshTiles:(NSString *)filter completion:(void (^)(NSDictionary *, NSError *))completion
{
    [self requestTilesForFilter:filter withCursor:nil completion:completion];
}

- (ASYNC)getNextPage:(NSString *)filter withCursor:(NSString *)cursor completion:(void (^)(NSDictionary *, NSError *))completion
{
    [self requestTilesForFilter:filter withCursor:cursor completion:completion];
}

- (ASYNC)requestTilesForFilter:(NSString *)filter withCursor:(NSString *)cursor completion:(void (^)(NSDictionary *, NSError *))completion
{
    // TODO: filter appropriate url
    // TODO: Page size or rely on the servers internal batch size?
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kPageSizeKey] = TILE_PAGE_SIZE;
    if ([cursor length] > 0) {
        params[kCursorKey] = cursor;
    }
    
    // TODO: when filters are working
//    NSString *path = filter ? TILE_FILTER_PATH(filter) : kTilesPath;
    NSString *path = kTilesPath;
    
    [self.sessionManager GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (completion) completion(jsonResponse, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // TODO: Pull aferror to server error conversion out into category or something
        if (completion) completion(nil, error);
    }];
}

- (ASYNC)handleButtonPressWithPath:(NSString *)buttonPath completion:(void (^)(NSError *error))completion
{
    // TODO: extra args
    [self.sessionManager PUT:buttonPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // TODO: error handling if required
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // TODO: error parsing
        if (completion) completion(error);
    }];
}

@end
