//
//  CPTableHeaderView.h
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPTableHeaderView : UIView
- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame;
- (BOOL)scrollViewDidScroll:(UIScrollView *)scrollView;
@end
