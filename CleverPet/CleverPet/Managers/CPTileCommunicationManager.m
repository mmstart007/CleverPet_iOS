//
//  CPTileCommunicationManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-03.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileCommunicationManager.h"
#import "CPAppEngineCommunicationManager.h"

// TODO: appropriate path for filter
NSString * const kTilesPath = @"users/tiles";
#define TILE_FILTER_PATH(filter) [NSString stringWithFormat:@"users/tiles/%@", filter]
#define SPECIFIC_TILE_PATH(tileId) [NSString stringWithFormat:@"tiles/%@", tileId]
#define REMOVE_TILE(tileId) [NSString stringWithFormat:@"%@/remove", SPECIFIC_TILE_PATH(tileId)]
#define TILE_PAGE_SIZE @(5)

@interface CPTileCommunicationManager()

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
        
    }
    return self;
}

- (AFHTTPSessionManager*)sessionManager
{
    // Borrow the session manager from app engine communication manager so we don't need to manage auth in multiple places
    return [[CPAppEngineCommunicationManager sharedInstance] getSessionManager];
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
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kPageSizeKey] = TILE_PAGE_SIZE;
    if ([cursor length] > 0) {
        params[kCursorKey] = cursor;
    }
    
    NSString *path = filter ? TILE_FILTER_PATH(filter) : kTilesPath;
    
    [self.sessionManager GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (completion) completion(jsonResponse, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion(nil, [self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)handleButtonPressWithPath:(NSString *)buttonPath completion:(void (^)(NSError *error))completion
{
    // TODO: extra args
    [self.sessionManager PUT:buttonPath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // TODO: error handling if required
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

- (ASYNC)handleTileSwipe:(NSString *)tileId completion:(void (^)(NSError *))completion
{
    [self.sessionManager POST:REMOVE_TILE(tileId) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) completion([self convertAFNetworkingErrorToServerError:error]);
    }];
}

@end
