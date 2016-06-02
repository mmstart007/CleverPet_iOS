//
//  NSError+CleverPet.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-21.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "NSError+CleverPet.h"

@implementation NSError(CleverPet)

- (BOOL)isOfflineError
{
    if ([self.domain isEqualToString:NSURLErrorDomain]) {
        return self.code == NSURLErrorNetworkConnectionLost || self.code == NSURLErrorNotConnectedToInternet || self.code == NSURLErrorCannotConnectToHost || self.code == NSURLErrorCannotFindHost;
    }
    return NO;
}

@end
