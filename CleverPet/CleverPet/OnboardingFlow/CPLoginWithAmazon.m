//
//  CPLoginWithAmazon.m
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLoginWithAmazon.h"

@implementation CPLoginWithAmazon

+ (NSArray *)appRequestScopes
{
    return [NSArray arrayWithObjects:@"profile:user_id", nil];
}

@end
