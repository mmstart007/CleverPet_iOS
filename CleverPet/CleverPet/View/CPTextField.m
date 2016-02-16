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
    self.layer.shadowColor = [UIColor colorWithWhite:0.f alpha:.15f].CGColor;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(0.f, 3.f);
    
    self.textColor = [UIColor appSignUpHeaderTextColor];
    self.font = [UIFont cpLightFontWithSize:kTextFieldFontSize italic:NO];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 2*kCPTextFieldHorizontalInset, 0.f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 2*kCPTextFieldHorizontalInset, 0.f);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGSize textSize = [self.placeholder sizeWithAttributes:@{NSFontAttributeName:self.font}];
    return CGRectMake((bounds.size.width - textSize.width)*.5f, bounds.origin.y, textSize.width, bounds.size.height);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor appTextFieldPlaceholderColor], NSFontAttributeName: self.font};
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
