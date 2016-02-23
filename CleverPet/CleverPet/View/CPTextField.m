//
//  CPTextField.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTextField.h"

CGFloat const kCPTextFieldHorizontalInset = 10.f;

@interface CPTextField()

@property (nonatomic, weak) UIView *stripeView;

@end

@implementation CPTextField

- (void)awakeFromNib
{
    // TODO: add teal stripe and background color/drop shadow for programatically created text fields
    self.backgroundColor = [UIColor appWhiteColor];
    UIView *stripe = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 5.f, self.bounds.size.height)];
    stripe.backgroundColor = [UIColor appTealColor];
    [self addSubview:stripe];
    self.stripeView = stripe;
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowColor = [UIColor colorWithWhite:0.15f alpha:1.f].CGColor;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    
    self.textColor = [UIColor appSignUpHeaderTextColor];
    self.font = [UIFont cpLightFontWithSize:15.f italic:NO];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor appTextFieldPlaceholderColor], NSFontAttributeName:self.font}]];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 2*kCPTextFieldHorizontalInset, 0.5f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 2*kCPTextFieldHorizontalInset, 0.5f);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
