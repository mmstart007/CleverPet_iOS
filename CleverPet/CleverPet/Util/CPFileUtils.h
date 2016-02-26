//
//  CPFileUtils.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPFileUtils : NSObject

+ (void)saveImage:(UIImage*)image forPet:(NSString*)petId;
+ (UIImage*)getImageForPet:(NSString*)petId;

@end
