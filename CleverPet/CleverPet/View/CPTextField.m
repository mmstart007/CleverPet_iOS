//
//  CPTextField.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTextField.h"

CGFloat const kCPTextFieldDefaultHorizontalInset = 0.f;

@interface CPTextField()

@property (nonatomic, weak) UIView *stripeView;

@end

@implementation CPTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup defaults for our inspectable properties
        self.showStripe = NO;
        self.showDropShadow = NO;
        self.horizontalTextInset = kCPTextFieldDefaultHorizontalInset;
        self.fontSize = 15;
    }
    return self;
}

- (void)awakeFromNib
{
    // TODO: add teal stripe and background color/drop shadow for programatically created text fields
    // TODO: add/remove stripe/drop shadow when values are updated if we need to support changing types
    self.backgroundColor = [UIColor appWhiteColor];
    
    if (self.showStripe) {
        UIView *stripe = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 5.f, self.bounds.size.height)];
        stripe.backgroundColor = [UIColor appTealColor];
        [self addSubview:stripe];
        self.stripeView = stripe;
    }
    
    if (self.showDropShadow) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.layer.shadowColor = [UIColor colorWithWhite:0.15f alpha:1.f].CGColor;
        self.layer.shadowRadius = 3;
        self.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    }
    
    self.textColor = [UIColor appTitleTextColor];
    self.font = [UIFont cpLightFontWithSize:self.fontSize italic:NO];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor appTextFieldPlaceholderColor], NSFontAttributeName:self.font}]];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (BOOL)resignFirstResponder
{
    BOOL resigned = [super resignFirstResponder];
    // Fix for text jumping when moving to next text field
    [self layoutIfNeeded];
    return resigned;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
