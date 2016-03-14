//
//  CPChartRenderer.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-11.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPChartRenderer.h"
#import "CPGraph.h"
#import "CPGraphView.h"

@interface CPChartRenderer ()
@property (strong, nonatomic) CPGraphView *graphView;
@property (strong, nonatomic) dispatch_queue_t queue;
@end

@implementation CPChartRenderer
+ (instancetype)sharedInstance {
    static CPChartRenderer *s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[CPChartRenderer alloc] init];
    });
    
    return s_instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.graphView = [[CPGraphView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.queue = dispatch_queue_create("CPChartRenderer", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)renderChart:(CPGraph *)graph ofSize:(CGSize)size withCallback:(CPChartRendererCallback)callback {
    dispatch_async(self.queue, ^{
        self.graphView.frame = CGRectMake(0, 0, size.width, size.height);
        self.graphView.graphData = graph;
        UIImage *image = self.graphView.hostedGraph.imageOfLayer;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}
@end
