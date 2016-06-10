//
//  CPSplashImageUtils.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-10.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSplashImageUtils.h"

@implementation CPSplashImageUtils

+ (UIImage*)getSplashImage
{
    NSNumber *screenHeight = @([UIScreen mainScreen].bounds.size.height);
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"splash-%@", screenHeight]];
}

@end
