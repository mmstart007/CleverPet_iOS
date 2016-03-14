//
//  CPGraphDataSource.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPGraphView.h"
#import "CPGraph.h"

@import CoreText;

#define kTopPlotIdentifier @"top"
#define kBottomPlotIdentifier @"bottom"

@interface CPGraphView ()
@property(nonatomic, strong) CPTXYGraph *graph;
@property(nonatomic, strong) NSArray<CPTPlot *> *plots;
@end

@implementation CPGraphView
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
    }
    
    return self;
}

- (void)setGraphData:(CPGraph *)graphData {
    _graphData = graphData;
    
    for (CPTPlot *plot in self.plots) {
        [self.graph removePlot:plot];
    }
    self.plots = nil;
    
    if (self.graphData) {
        self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
        self.hostedGraph = self.graph;
        self.graph.plotAreaFrame.masksToBorder = NO;
        self.graph.paddingLeft = 32;
        self.graph.paddingRight = 32;
        self.graph.paddingTop = 32;
        self.graph.paddingBottom = 32;
        self.graph.borderLineStyle = nil;
        self.graph.plotAreaFrame.borderLineStyle = nil;
        
        self.graph.topDownLayerOrder = @[@(CPTGraphLayerTypeAxisLines)];
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
        plotSpace.delegate = self;
        double offset = 0.5;
        
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(offset)
                                                        length:@(self.graphData.series[0].data.count + 0.1)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0
                                                        length:self.graphData.yMax];
        
        CPTMutableLineStyle *axisLineStyle = [[CPTMutableLineStyle alloc] init];
        axisLineStyle.lineWidth = 2;
        axisLineStyle.lineColor = [CPTColor colorWithCGColor:[UIColor appTextFieldPlaceholderColor].CGColor];
        
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
        
        CPTXYAxis *xAxis = axisSet.xAxis;
        xAxis.orthogonalPosition = @(0);
        xAxis.majorIntervalLength = @1;
        xAxis.minorTicksPerInterval = 0;
        xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
        xAxis.axisLineStyle = axisLineStyle;
        
        UIFont *font = [UIFont cpMediumFontWithSize:12 italic:NO];
        CPTMutableTextStyle *xAxisTextStyle = [CPTMutableTextStyle textStyle];
        xAxisTextStyle.fontName = font.fontName;
        xAxisTextStyle.fontSize = font.pointSize;
        xAxisTextStyle.color = [CPTColor colorWithCGColor:[UIColor appSubCopyTextColor].CGColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineHeightMultiple = .9;
        
        NSMutableSet *axisLabels = [[NSMutableSet alloc] init];
        for (NSUInteger i = 0; i < self.graphData.xAxisLabels.count; i++) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] init];
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.graphData.xAxisLabels[i]
                                                                                     attributes:@{
                                                                                                  NSFontAttributeName:[UIFont cpRegularFontWithSize:12 italic:NO],
                                                                                                  NSForegroundColorAttributeName:[UIColor appSubCopyTextColor]
                                                                                                  }]];
            //        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            //        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", self.graphData.bottomData[i].doubleValue]
            //                                                                                 attributes:@{
            //                                                                                              NSFontAttributeName:[UIFont cpSemiboldFontWithSize:12 italic:NO],
            //                                                                                              NSForegroundColorAttributeName:[UIColor appSubCopyTextColor]
            //                                                                                              }]];
            
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
            
            CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithAttributedText:attributedString];
            label.contentLayer = textLayer;
            
            label.tickLocation = @(self.graphData.xAxisTicks[i].doubleValue + 1);
            label.offset = xAxis.labelOffset;
            [axisLabels addObject:label];
        }
        
        xAxis.axisLabels = axisLabels;
        
        CPTXYAxis *yAxis = axisSet.yAxis;
        yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        yAxis.orthogonalPosition = @(0.5);
        yAxis.axisLineStyle = axisLineStyle;
        
        axisLabels = [[NSMutableSet alloc] init];
        for (NSUInteger i = 0; i < self.graphData.yAxisTicks.count; i++) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:self.graphData.yAxisLabels[i]
                                                           textStyle:xAxisTextStyle];
            label.offset = yAxis.labelOffset;
            label.tickLocation = self.graphData.yAxisTicks[i];
            [axisLabels addObject:label];
        }
        
        yAxis.axisLabels = axisLabels;
        
        NSMutableArray *plots = [[NSMutableArray alloc] init];
        for (NSInteger i = self.graphData.series.count - 1; i >= 0; --i) {
            CPGraphSeries *series = self.graphData.series[i];
            NSNumber *plotIdentifier = @(i);
            CPTBarPlot *plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
            plot.identifier = plotIdentifier;
            plot.barBasesVary = YES;
            plot.barWidthsAreInViewCoordinates = YES;
            plot.barWidth = @4;
            plot.dataSource = self;
            plot.lineStyle = nil;
            
            plot.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[series uiColor].CGColor]];
            
            [self.graph addPlot:plot toPlotSpace:plotSpace];
            [plots addObject:plot];
        }
        
        self.plots = plots;
        
        [self.hostedGraph reloadData];
    } else {
        self.graph = nil;
        self.hostedGraph = nil;
    }
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.graphData.series[0].data.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    switch (fieldEnum) {
        case CPTBarPlotFieldBarLocation:
            return @(idx + 1);
            break;
        case CPTBarPlotFieldBarBase:
            return @0;
            break;
        case CPTBarPlotFieldBarTip:
        {
            NSUInteger seriesIndex = ((NSNumber *)plot.identifier).unsignedIntegerValue;
            double topValue = 0;
            
            for (NSUInteger i = 0; i <= seriesIndex; i++) {
                topValue += self.graphData.series[seriesIndex].data[idx].doubleValue;
            }
            
            return @(topValue);
        }
            break;
    }
    
    return nil;
}
@end
