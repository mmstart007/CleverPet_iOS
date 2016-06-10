//
//  CPHubSettingsButton.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-19.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPHubSettingsButton.h"

CGFloat const kHubButtonSize = 33.f;
CGFloat const kHubButtonBorderWidth = 3.f;

@implementation CPHubSettingsButton

+ (UIImage *)unselectedImage
{
    static dispatch_once_t onceToken;
    static UIImage *s_unselectedImage;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kHubButtonSize, kHubButtonSize), NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kHubButtonSize, kHubButtonSize) cornerRadius:kHubButtonSize*.5f];
        [[UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0] setFill];
        [path fill];
        s_unselectedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return s_unselectedImage;
}

+ (UIImage *)selectedImage
{
    static dispatch_once_t onceToken;
    static UIImage *s_selectedImage;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kHubButtonSize, kHubButtonSize), NO, [UIScreen mainScreen].scale);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kHubButtonSize, kHubButtonSize) cornerRadius:kHubButtonSize*.5f];
        [[UIColor appTealColor] setFill];
        [path fill];
        
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(kHubButtonBorderWidth, kHubButtonBorderWidth, kHubButtonSize - 2*kHubButtonBorderWidth, kHubButtonSize - 2*kHubButtonBorderWidth) cornerRadius:(kHubButtonSize - 2*kHubButtonBorderWidth)*.5f];
        [[UIColor appWhiteColor] setFill];
        [path fill];
        
        s_selectedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return s_selectedImage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupImages];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupImages];
}

- (void)setupImages
{
    self.contentMode = UIViewContentModeRight;
    self.imageView.contentMode = UIViewContentModeRight;
    self.backgroundColor = [UIColor clearColor];
    // Monkey with the insets to get the image to align to the right
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width - (kHubButtonSize + 2*kHubButtonBorderWidth), 0, 0);
    [self setImage:[CPHubSettingsButton unselectedImage] forState:UIControlStateNormal];
    [self setImage:[CPHubSettingsButton unselectedImage] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self setImage:[CPHubSettingsButton selectedImage] forState:UIControlStateHighlighted];
    [self setImage:[CPHubSettingsButton selectedImage] forState:UIControlStateSelected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
