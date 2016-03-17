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

// TODO: other templates
typedef NS_ENUM(NSUInteger){
    CPTileTemplateMessage,
    CPTileTemplateVideo,
    CPTileTemplateReport
}CPTileTemplate;

@class CPGraph;
@interface CPTile : JSONModel
// Persisted properties
@property (nonatomic, strong) NSString *category;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic, strong) NSURL<Optional> *imageUrl;
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) NSString<Optional> *primaryButtonText;
@property (nonatomic, strong) NSString<Optional> *primaryButtonUrl;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) NSString<Optional> *secondaryButtonText;
@property (nonatomic, strong) NSString<Optional> *secondaryButtonUrl;
// TODO: Template v category nonsense
@property (nonatomic, strong) NSString<Optional> *template;
@property (nonatomic, strong) NSString *tileId;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, assign) BOOL userDeletable;

@property (nonatomic, strong) NSNumber<Optional> *removed;

// TODO: can probably remove
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSURL<Optional> *videoThumbnailUrl;
@property (nonatomic, strong) NSURL<Optional> *videoUrl;

@property (assign, nonatomic) CPTileType tileType;
@property (assign, nonatomic) CPTileTemplate templateType;

// Non-persisted properties
@property (strong, nonatomic) NSAttributedString<Ignore>*parsedBody;
@property (strong, nonatomic) CPSimpleDate<Ignore> *simpleDate;

@property (assign, nonatomic) CGFloat cachedRowHeight;

@property (strong, nonatomic) CPGraph<Optional> *graph;

+(void)setTimeZoneOffset:(NSInteger)offset;
@end