//
//  CPReportGraphHolder.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPReportGraphHolder.h"
#import "CPGraph.h"
#import "CPGraphView.h"
#import "CPChartRenderer.h"

@interface CPReportGraphHolder ()

@property (strong, nonatomic) NSLayoutConstraint *graphViewAspectRatioConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *graphView;
@property (weak, nonatomic) IBOutlet UITextView *chartTitleView;
@end

@implementation CPReportGraphHolder {
    CPGraph *_graph;
}

- (CPGraph*)graph
{
    return _graph;
}

- (void)setGraph:(CPGraph *)graph forSizing:(BOOL)forSizing{
    _graph = graph;
    
    if (self.graphViewAspectRatioConstraint) {
        [self.graphView removeConstraint:self.graphViewAspectRatioConstraint];
    }
    
    if (graph) {
        self.graphViewAspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self.graphView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.graphView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:graph.aspectRatio.doubleValue
                                                                            constant:0];
        [self.graphView addConstraint:self.graphViewAspectRatioConstraint];
        [self.graphView setNeedsLayout];
        
        CGSize imageSize = CGSizeZero;
        imageSize.width = [UIScreen mainScreen].bounds.size.width - 32;
        imageSize.height = imageSize.width * graph.aspectRatio.floatValue;
        
        // Skip rendering the chart we're calculating row size
        if (!forSizing) {
            [[CPChartRenderer sharedInstance] renderChart:graph ofSize:imageSize withCallback:^(UIImage *renderedChart) {
                self.graphView.image = renderedChart;
            }];
        }
        
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
        
        [titleString appendAttributedString:[[NSAttributedString alloc] initWithString:graph.graphTitle
                                                                            attributes:@{
                                                                                         NSFontAttributeName:[UIFont cpRegularFontWithSize:15 italic:NO],
                                                                                         NSForegroundColorAttributeName:[UIColor appTitleTextColor]
                                                                                                                     }]];
        [titleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        for (NSUInteger i = 0; i < graph.series.count; i++) {
            CPGraphSeries *series = graph.series[i];
            
            [titleString appendAttributedString:[[NSAttributedString alloc] initWithString:@"   "]];
            
            [titleString appendAttributedString:[[NSAttributedString alloc] initWithString:@"●\u00a0"
                                                                                attributes:@{
                                                                                             NSFontAttributeName:[UIFont cpRegularFontWithSize:10 italic:NO],
                                                                                             NSForegroundColorAttributeName:[series uiColor]
                                                                                             }]];
            [titleString appendAttributedString:[[NSAttributedString alloc] initWithString:[series.name stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"]
                                                                                attributes:@{
                                                                                             NSFontAttributeName:[UIFont cpLightFontWithSize:10 italic:NO],
                                                                                             NSForegroundColorAttributeName:[UIColor appTitleTextColor]
                                                                                             }]];
        }
        
        self.chartTitleView.attributedText = titleString;
    } else {
        self.chartTitleView.text = nil;
    }
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if (self.tag == -999) {
        return self;
    }
    
    CPReportGraphHolder *view = [[NSBundle mainBundle] loadNibNamed:@"CPReportGraphHolder" owner:nil options:nil][0];
    
    view.frame = self.frame;
    view.autoresizingMask = self.autoresizingMask;
    view.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;
    view.tag = self.tag;
    
    return view;
}
@end
