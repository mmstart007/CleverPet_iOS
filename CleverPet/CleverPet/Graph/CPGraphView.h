//
//  CPGraphDataSource.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot/ios/CorePlot.h>

@class CPGraph;
@interface CPGraphView : CPTGraphHostingView <CPTPlotDataSource, CPTPlotSpaceDelegate>
@property(nonatomic, strong) CPGraph *graphData;
@end
