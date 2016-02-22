//
//  CPParticleConnectionHelper.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-22.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPParticleConnectionHelper : NSObject

+ (instancetype)sharedInstance;

- (void)applyConfig:(NSDictionary *)config;
- (void)setAuthToken:(NSString *)authToken;
- (void)presentSetupControllerOnController:(UIViewController*)controller;

@end
