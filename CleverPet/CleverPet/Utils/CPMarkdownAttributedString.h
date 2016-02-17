//
// Created by Daryl at Finger Foods on 2016-02-16.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CPMarkdownAttributedString : NSObject
+ (NSAttributedString *)attributedStringFromMarkdownString:(NSString *)markdownString;
@end