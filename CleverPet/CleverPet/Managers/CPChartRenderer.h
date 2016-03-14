//
//  CPChartRenderer.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPGraph;
typedef void(^CPChartRendererCallback)(UIImage *renderedChart);

@interface CPChartRenderer : NSObject
+ (instancetype)sharedInstance;
- (void)renderChart:(CPGraph *)graph ofSize:(CGSize)size withCallback:(CPChartRendererCallback)callback;
@end
