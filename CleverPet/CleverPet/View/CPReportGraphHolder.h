//
//  CPReportGraphHolder.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPGraph;
@class CPGraphView;
@interface CPReportGraphHolder : UIView

@property (strong, nonatomic) CPGraph *graph;
@end