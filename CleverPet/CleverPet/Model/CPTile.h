//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

@import UIKit;
#import <JSONModel/JSONModel.h>
#import "CPSimpleDate.h"

typedef NS_ENUM(NSUInteger) {
    CPTTMessage,
    CPTTReport,
    CPTTChallenge,
    CPTTVideo,
    CPTTMac,
} CPTileType;

@interface CPTile : JSONModel
// Persisted properties
@property (nonatomic, strong) NSString *category;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic, strong) NSString<Optional> *imageUrl;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString<Optional> *primaryButtonText;
@property (nonatomic, strong) NSString<Optional> *primaryButtonUrl;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) NSString<Optional> *secondaryButtonText;
@property (nonatomic, strong) NSString<Optional> *secondaryButtonUrl;
// TODO: Template v category nonsense
@property (nonatomic, strong) NSString *template;
@property (nonatomic, strong) NSString *tileId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL userDeletable;
// TODO: can probably remove
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString<Optional> *videoThumbnailUrl;
@property (nonatomic, strong) NSString *videoUrl;

@property (assign, nonatomic) CPTileType tileType;

// Non-persisted properties
@property (strong, nonatomic) NSAttributedString<Ignore>*parsedBody;
@property (strong, nonatomic) CPSimpleDate<Ignore> *simpleDate;

@property (assign, nonatomic) CGFloat cachedRowHeight;
@end