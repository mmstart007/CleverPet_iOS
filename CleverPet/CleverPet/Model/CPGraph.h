//
//  CPGraph.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CPGraph : JSONModel
@property (strong, nonatomic) NSArray<NSNumber *> *topData;
@property (strong, nonatomic) NSArray<NSNumber *> *bottomData;
@property (strong, nonatomic) NSArray<NSString *> *xAxisLabels;
@property (strong, nonatomic) NSString *graphTitle;
@property (strong, nonatomic) NSString *topSeriesTitle;
@property (strong, nonatomic) NSString *bottomSeriesTitle;
@property (strong, nonatomic) NSNumber *yMin;
@property (strong, nonatomic) NSNumber *yMax;
@end
