//
//  CPLoadingView.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-26.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPLoadingView.h"

@interface CPLoadingView()

@property (nonatomic, weak) UIActivityIndicatorView *spinner;

@end

@implementation CPLoadingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithWhite:1.f alpha:.5f];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner startAnimating];
    spinner.color = [UIColor appTealColor];
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:spinner];
    self.spinner = spinner;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
    [self addConstraints:@[centerX, centerY]];
    [self layoutIfNeeded];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end