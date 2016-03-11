//
//  CPBaseCommunicationManager.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface CPBaseCommunicationManager : NSObject

- (NSError *)convertAFNetworkingErrorToServerError:(NSError*)error;
- (NSError *)errorForMessage:(NSString *)message;

@end
