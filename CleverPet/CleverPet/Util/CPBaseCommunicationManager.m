//
//  CPBaseCommunicationManager.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPBaseCommunicationManager.h"

@implementation CPBaseCommunicationManager

- (NSError *)convertAFNetworkingErrorToServerError:(NSError*)error
{
    if ( ![error.domain isEqualToString:AFURLResponseSerializationErrorDomain] || error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] == nil) {
        return error;
    }
    
    NSInteger errorCode = [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:nil];
    NSString *errorMessage = responseDict[kErrorKey] ? responseDict[kErrorKey] : [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSError *newError = [NSError errorWithDomain:NSStringFromClass([self class]) code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
    return newError;
}

- (NSError*)errorForMessage:(NSString *)message
{
    // TODO: error codes
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey:message}];
}

@end
