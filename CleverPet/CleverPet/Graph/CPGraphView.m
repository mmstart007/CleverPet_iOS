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
@end

@implementation CPGraphView
- (void)setGraphData:(CPGraph *)graphData {
    _graphData = graphData;
    
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
                                                    length:@(self.graphData.topData.count + 0.1 - offset)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:self.graphData.yMin
                                                    length:@(self.graphData.yMax.doubleValue - self.graphData.yMin.doubleValue)];
    
    CPTMutableLineStyle *axisLineStyle = [[CPTMutableLineStyle alloc] init];
    axisLineStyle.lineWidth = 1;
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
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", self.graphData.bottomData[i].doubleValue]
                                                                                 attributes:@{
                                                                                              NSFontAttributeName:[UIFont cpSemiboldFontWithSize:12 italic:NO],
                                                                                              NSForegroundColorAttributeName:[UIColor appSubCopyTextColor]
                                                                                              }]];
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithAttributedText:attributedString];
        label.contentLayer = textLayer;
        
        label.tickLocation = @(i + 1);
        label.offset = xAxis.labelOffset;
        [axisLabels addObject:label];
    }
    
    xAxis.axisLabels = axisLabels;
    
    CPTXYAxis *yAxis = axisSet.yAxis;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    yAxis.orthogonalPosition = @(0.5);
    
    axisLabels = [[NSMutableSet alloc] init];
    for (NSNumber *yLabelValue in @[self.graphData.yMin, self.graphData.yMax]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:yLabelValue.stringValue
                                                       textStyle:xAxisTextStyle];
        label.offset = yAxis.labelOffset;
        if (yLabelValue == self.graphData.yMin) {
            label.tickLocation = yLabelValue;
        } else if (yLabelValue == self.graphData.yMax) {
            label.tickLocation = yLabelValue;
        }
        
        [axisLabels addObject:label];
    }
    
    yAxis.axisLabels = axisLabels;
    
    
    for (NSString *plotIdentifier in @[kTopPlotIdentifier, kBottomPlotIdentifier]) {
        CPTBarPlot *plot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
        plot.identifier = plotIdentifier;
        plot.barBasesVary = YES;
        plot.barWidthsAreInViewCoordinates = YES;
        plot.barWidth = @4;
        plot.dataSource = self;
        plot.lineStyle = nil;
        
        if ([plotIdentifier isEqualToString:kTopPlotIdentifier]) {
            plot.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor appLightOrangeColor].CGColor]];
        } else if ([plotIdentifier isEqualToString:kBottomPlotIdentifier]) {
            plot.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor appOrangeColor].CGColor]];
        }
        
        [self.graph addPlot:plot toPlotSpace:plotSpace];
    }
    
    [self.hostedGraph reloadData];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.graphData.topData.count;
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
            if ([plot.identifier isEqual:kBottomPlotIdentifier]) {
                return self.graphData.bottomData[idx];
            } else {
                return @(self.graphData.bottomData[idx].doubleValue + self.graphData.topData[idx].doubleValue);
            }
            break;
    }
    
    return nil;
}
@end
