//
//  CPMainTableSectionHeader.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPMainTableSectionHeader.h"
#include "CPMainTableSectionHeaderFilter.h"

@interface CPMainTableSectionHeader ()
@property (strong, nonatomic) NSMutableArray<CPMainTableSectionHeaderFilter *> *filters;
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *filterConstraints;
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *verticalConstraints;
@property (strong, nonatomic) NSMutableArray<UILabel *> *filterLabels;
@property (assign, nonatomic) NSUInteger currentFilter;

@property (weak, nonatomic) IBOutlet UILabel *lastLabel;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (assign, nonatomic) NSUInteger index;
@end

@implementation CPMainTableSectionHeader
- (void)awakeFromNib
{
    self.clipsToBounds = NO;
    
    self.contentView.backgroundColor = [UIColor appBackgroundColor];
    self.filters = [[NSMutableArray alloc] init];
    self.filterConstraints = [[NSMutableArray alloc] init];
    self.verticalConstraints = [[NSMutableArray alloc] init];
    self.filterLabels = [[NSMutableArray alloc] init];
    
    self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
    self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
    self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:self.swipeRightGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapGestureRecognized:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    self.clipsToBounds = YES;
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.swipeLeftGestureRecognizer) {
        if (self.currentFilter < self.filters.count - 1) {
            [self setCurrentFilter:self.currentFilter + 1 withAnimation:YES];
            [self.delegate sectionHeader:self didChangeToFilter:self.filters[self.currentFilter]];
        }
    } else if(gestureRecognizer == self.swipeRightGestureRecognizer) {
        if (self.currentFilter > 0) {
            [self setCurrentFilter:self.currentFilter - 1 withAnimation:YES];
            [self.delegate sectionHeader:self didChangeToFilter:self.filters[self.currentFilter]];
        }
    }
}

- (void)labelTapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint location = [tapGestureRecognizer locationInView:self];
    for (NSUInteger i = 0; i < self.filterLabels.count; i++) {
        UILabel *label = self.filterLabels[i];
        if (CGRectGetMinX(label.frame) <= location.x && CGRectGetMaxX(label.frame) >= location.x) {
            [self setCurrentFilter:i withAnimation:YES];
            [self.delegate sectionHeader:self didChangeToFilter:self.filters[self.currentFilter]];
            
            break;
        }
    }
}

- (void)prepareForReuse {
}

- (void)setShouldShowFilters:(BOOL)shouldShowFilters {
    for (UILabel *label in self.filterLabels) {
        label.hidden = !shouldShowFilters;
    }
}

- (void)setCurrentFilterObject:(CPMainTableSectionHeaderFilter *)filterObject withAnimation:(BOOL)animate {
    NSUInteger index = [self.filters indexOfObject:filterObject];
    [self setCurrentFilter:index withAnimation:animate];
}

- (void)setCurrentFilter:(NSUInteger)currentFilter withAnimation:(BOOL)animate {
    [self setLayoutOffsetForLabel:currentFilter withAnimation:animate];
    _currentFilter = currentFilter;
}

- (void)setLayoutOffsetForLabel:(NSUInteger)labelIndex withAnimation:(BOOL)animate
{
    if (animate) {
        [self.layer removeAllAnimations];
        [self layoutIfNeeded];
    }
    
    for (NSLayoutConstraint *constraint in self.filterConstraints) {
        constraint.priority = 1;
    }
    
    self.filterConstraints[labelIndex].priority = 999;
    
    if (animate) {
        [UIView animateWithDuration:.2 animations:^{
            [self layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
}

- (void)addFilter:(CPMainTableSectionHeaderFilter *)filter withColor:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.text = filter.filterName;
    [self addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.filterLabels addObject:label];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self addConstraint:centerXConstraint];
    centerXConstraint.priority = 1;
    
    [self.filterConstraints addObject:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraint:centerYConstraint];
    centerYConstraint.priority = 1000;
    
    [self.verticalConstraints addObject:centerYConstraint];
    
    UIView *colorDotView;
    if (color) {
        colorDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.f, 4.f)];
        colorDotView.translatesAutoresizingMaskIntoConstraints = NO;
        colorDotView.layer.cornerRadius = colorDotView.bounds.size.width*.5f;
        colorDotView.backgroundColor = color;
        [self addSubview:colorDotView];
        NSLayoutConstraint *colorHeight = [NSLayoutConstraint constraintWithItem:colorDotView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:4.f];
        [self addConstraint:colorHeight];
        NSLayoutConstraint *colorWidth = [NSLayoutConstraint constraintWithItem:colorDotView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:4.f];
        [self addConstraint:colorWidth];
        NSLayoutConstraint *colorX = [NSLayoutConstraint constraintWithItem:colorDotView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self addConstraint:colorX];
        NSLayoutConstraint *colorSpacing = [NSLayoutConstraint constraintWithItem:colorDotView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1 constant:0.f];
        [self addConstraint:colorSpacing];
    }
    
    if (self.lastLabel) {
        NSLayoutConstraint *spacingConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.lastLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:32];
        [self addConstraint:spacingConstraint];
    } else {
        [self setCurrentFilter:0 withAnimation:NO];
    }
    
    [self.filters addObject:filter];
    
    self.lastLabel = label;
    
    label.font = [UIFont cpExtraLightFontWithSize:15 italic:NO];
    label.textColor = [UIColor appSubCopyTextColor];
}

- (void)setVerticalFilterLabelOffset:(CGFloat)verticalFilterLabelOffset {
    for (NSLayoutConstraint *constraint in self.verticalConstraints) {
        constraint.constant = verticalFilterLabelOffset;
    }
    
    [self layoutIfNeeded];
}
@end
