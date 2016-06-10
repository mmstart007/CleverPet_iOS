//
//  CPParticleConnectionHelper.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-22.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPParticleConnectionDelegate <NSObject>

- (void)deviceClaimed:(NSDictionary*)deviceInfo;
- (void)deviceClaimFailed;
- (void)deviceClaimCanceled;

@end

@interface CPParticleConnectionHelper : NSObject

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary *)config;
- (void)setAccessToken:(NSDictionary*)tokenInfo completion:(void (^)(NSError *error))completion;
- (void)presentSetupControllerOnController:(UINavigationController*)controller withDelegate:(id<CPParticleConnectionDelegate>)delegate;

@end
