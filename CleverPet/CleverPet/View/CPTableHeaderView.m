//
//  CPTableHeaderView.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTableHeaderView.h"

@interface CPTableHeaderView ()
@property (strong, nonatomic) NSLayoutConstraint *heightLayoutConstraint, *bottomLayoutConstraint, *containerLayoutConstraint;

@property (strong, nonatomic) UIView *containerView;

@property (assign, nonatomic) CGFloat originalHeight;
@end

@implementation CPTableHeaderView
- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.originalHeight = frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.containerView = [[UIView alloc] init];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.backgroundColor = [UIColor redColor];
        [self addSubview:self.containerView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:0 metrics:nil views:@{@"containerView":self.containerView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[containerView]|" options:0 metrics:nil views:@{@"containerView":self.containerView}]];
        self.containerLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self addConstraint:self.containerLayoutConstraint];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = image;
        [self.containerView addSubview:imageView];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView":imageView}]];
        self.bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self.containerView addConstraint:self.bottomLayoutConstraint];
        self.heightLayoutConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.containerView addConstraint:self.heightLayoutConstraint];
    }
    
    return self;
}

- (BOOL)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.containerLayoutConstraint.constant = scrollView.contentInset.top;
    CGFloat offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
    self.containerView.clipsToBounds = offsetY <= 0;
    self.bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2;
    self.heightLayoutConstraint.constant = MAX(offsetY + scrollView.contentInset.top, scrollView.contentInset.top);
    
    return scrollView.contentOffset.y < (self.originalHeight - 4);
}
@end
