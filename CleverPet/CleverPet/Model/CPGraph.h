//
//  CPGraph.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol CPGraphSeries <NSObject>

@end

@interface CPGraphSeries : JSONModel
+ (NSDictionary *)colorMapping;

@property (strong, nonatomic) NSArray<NSNumber *> *data;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *color;

- (UIColor *)uiColor;
@end

@interface CPGraph : JSONModel
@property (strong, nonatomic) NSArray<CPGraphSeries *> <CPGraphSeries> *series;

@property (strong, nonatomic) NSArray<NSString *> <Optional> *xAxisLabels;
@property (strong, nonatomic) NSArray<NSNumber *> <Optional> *xAxisTicks;

@property (strong, nonatomic) NSArray<NSString *> <Optional> *yAxisLabels;
@property (strong, nonatomic) NSArray<NSNumber *> <Optional> *yAxisTicks;

@property (strong, nonatomic) NSNumber<Optional> *hasLegend;

@property (strong, nonatomic) NSString *graphTitle;
@property (strong, nonatomic) NSNumber *yMax;

@property (strong, nonatomic) NSNumber *aspectRatio;
@end
