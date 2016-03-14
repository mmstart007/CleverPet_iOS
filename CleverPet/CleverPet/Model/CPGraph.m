//
//  CPGraph.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-03-09.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPGraph.h"

@implementation CPGraphSeries
+ (NSDictionary *)colorMapping {
    static NSDictionary *s_mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_mapping = @{
                      @"red":[UIColor appRedColor],
                      @"lightRed":[UIColor appLightRedColor],
                      @"green":[UIColor appGreenColor],
                      @"lightGreen":[UIColor appLightGreenColor],
                      @"teal":[UIColor appTealColor],
                      @"lightTeal":[UIColor appLightTealColor],
                      @"yellow":[UIColor appYellowColor],
                      @"lightYellow":[UIColor appLightYellowColor],
                      @"orange":[UIColor appOrangeColor],
                      @"lightOrange":[UIColor appLightOrangeColor],
                      @"white":[UIColor appWhiteColor],
                      @"black":[UIColor appBlackColor],
                      };
    });
    
    return s_mapping;
}

- (UIColor *)uiColor {
    UIColor *color = [[self class] colorMapping][self.color];
    if (!color) {
        color = [UIColor blackColor];
    }
    return color;
}

+ (JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{}];
}
@end

@implementation CPGraph
+ (JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{}];
}
@end
