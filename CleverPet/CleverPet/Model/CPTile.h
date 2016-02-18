//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

@import UIKit;
#import <JSONModel/JSONModel.h>

@interface CPTile : NSObject
// Persisted properties
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIImage *image;

@property (assign, nonatomic) BOOL hasLeftButton, hasRightButton;

// Non-persisted properties
@property (strong, nonatomic) NSAttributedString<Ignore>*parsedBody;
@end