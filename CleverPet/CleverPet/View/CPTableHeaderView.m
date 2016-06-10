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
@property (nonatomic, weak) UIImageView *imageView;

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
        self.containerView.backgroundColor = [UIColor appWhiteColor];
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
        self.imageView = imageView;
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView":imageView}]];
        self.bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self.containerView addConstraint:self.bottomLayoutConstraint];
        self.heightLayoutConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.containerView addConstraint:self.heightLayoutConstraint];
    }
    
    return self;
}

- (void)updateImage:(UIImage *)image
{
    if (![self.imageView.image isEqual:image]) {
        self.imageView.image = image;
    }
}

- (BOOL)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.containerLayoutConstraint.constant = scrollView.contentInset.top;
    CGFloat offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
    self.containerView.clipsToBounds = offsetY <= 0;
    
    CGFloat bottomConstant = offsetY >= 0 ? 0 : -offsetY / 2;
    
    if (self.bottomLayoutConstraint.constant != bottomConstant && -offsetY < self.originalHeight) {
        self.bottomLayoutConstraint.constant = bottomConstant;
    }
    
    CGFloat topConstant = MAX(offsetY + scrollView.contentInset.top, scrollView.contentInset.top);
    if (self.heightLayoutConstraint.constant != topConstant) {
        self.heightLayoutConstraint.constant = topConstant;
    }
    
    return scrollView.contentOffset.y < (self.originalHeight - 4);
}
@end
