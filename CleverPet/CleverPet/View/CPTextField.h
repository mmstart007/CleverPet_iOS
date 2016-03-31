//
//  CPTextField.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPTextField : UITextField

@property (nonatomic, assign) IBInspectable BOOL showStripe;
@property (nonatomic, assign) IBInspectable BOOL showDropShadow;
@property (nonatomic, assign) IBInspectable BOOL showCaret;
@property (nonatomic, assign) IBInspectable CGFloat horizontalTextInset;
@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@end
