//
//  CPReplenishDashUtil.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReplenishDashUtil.h"
#import "CPUserManager.h"
#include <CommonCrypto/CommonDigest.h>

#define URL_FOR_LWA_PAGE                @"lwa://login"
#define COMPOSITE_ID_FOR_TEASER         @"amzn1.dash.v1.composite.7a3b2f2b-5371-4f74-9cbd-ef4ecd59c5ae"

@implementation CPReplenishDashUtil

+ (NSArray *)appRequestScopes
{
    return [NSArray arrayWithObjects:@"dash:replenish", nil];
}

+ (NSDictionary *)appRequestScopeOptions
{
    NSString *device_model_id = @"HB01";
    CPUser *currentUser = [[CPUserManager sharedInstance] getCurrentUser];
    NSString *device_id = currentUser.device.deviceId;
    NSString *is_test_device =
    //#ifdef DEBUG
#if 0
    @"true"
#else
    @"false"
#endif
    ;
    
    return @{kAIOptionScopeData : [NSString stringWithFormat:
                                   @"{ \"dash:replenish\":{ \"device_model\":\"%@\", \"serial\":\"%@\", \"is_test_device\":\"%@\" } }",
                                   device_model_id, device_id, is_test_device],
             kAIOptionReturnAuthCode : @YES,
//             kAIOptionCodeChallenge : [self createCodeChallenge:@"CleverPet Hub"],
//             kAIOptionCodeChallengeMethod : @"S256"};
//             kAIOptionCodeChallenge : @"CleverPet Hub",
             kAIOptionCodeChallenge : @"this_is_a_large_unique_string_or_hash_for_using_USER_ID_and_DEVICE_ID",
             kAIOptionCodeChallengeMethod : @"plain"};
}

#pragma Mark: Helper Methods (Make sure to add the Security Framework)
+ (NSString*)computeSHA256DigestForString:(NSString*)input
{
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i ++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *)createCodeChallenge:(NSString *)codeWord
{
    NSData *encryptedCode  = [[self computeSHA256DigestForString:codeWord] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *finalCode = [encryptedCode base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return finalCode;
}

+ (NSString *)urlForTeaserPage
{
    return [NSString stringWithFormat:@"https://drs-web.amazon.com/teaser?compositeId=%@&loginUri=%@", COMPOSITE_ID_FOR_TEASER, URL_FOR_LWA_PAGE];
}

+ (NSString *)urlForAmazonLoginPage
{
    return URL_FOR_LWA_PAGE;
}

@end
