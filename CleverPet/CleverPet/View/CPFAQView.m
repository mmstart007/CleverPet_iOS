//
//  CPFAQView.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPFAQView.h"
#import "OAStackView.h"

@interface CPFAQView()

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, weak) id stackView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UILabel *headerLabel;
@property (nonatomic, weak) UIButton *expandButton;
@property (nonatomic, weak) UITextView *bodyLabel;
@property (nonatomic, weak) UITapGestureRecognizer *tapRecognizer;

@end

@implementation CPFAQView

- (instancetype)initWithTitle:(NSString *)title andBody:(NSString *)body
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.isExpanded = NO;
        self.title = title;
        self.body = body;
        self.backgroundColor = [UIColor appWhiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupStackView];
    }
    return self;
}

- (void)setupStackView
{
    // Nonsense to use only use oastack view before 9. Not super happy about it, but to get decent animations for the demo
    // Not a robust way of checking
    id stack;
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        stack = [[OAStackView alloc] init];
    } else {
        stack = [[UIStackView alloc] init];
    }
    
    [stack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:stack];
    self.stackView = stack;
    [self.stackView setBackgroundColor:[UIColor clearColor]];
    [self.stackView setAxis:UILayoutConstraintAxisVertical];
    
    NSDictionary *viewsDict = @{@"stack":self.stackView};
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[stack]-15-|" options:kNilOptions metrics:nil views:viewsDict];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[stack]-15-|" options:kNilOptions metrics:nil views:viewsDict];
    [self addConstraints:verticalConstraints];
    [self addConstraints:horizontalConstraints];
    [self setupHeaderView];
}

- (void)setupHeaderView
{
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerLabel.numberOfLines = 0;
    headerLabel.text = self.title;
    headerLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    headerLabel.textColor = [UIColor appTitleTextColor];
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandButton.translatesAutoresizingMaskIntoConstraints = NO;
    [expandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
    [view addSubview:headerLabel];
    [view addSubview:expandButton];
    self.headerLabel = headerLabel;
    self.expandButton = expandButton;
    [self.expandButton addTarget:self action:@selector(expandButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *viewsDict = @{@"label":self.headerLabel, @"button":self.expandButton};
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label(>=40)]-0-|" options:kNilOptions metrics:nil views:viewsDict];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-15-[button(40)]-0-|" options:kNilOptions metrics:nil views:viewsDict];
    [view addConstraints:verticalConstraints];
    [view addConstraints:horizontalConstraints];
    
    // Button height
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.expandButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40.f]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self.expandButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    [self.stackView addArrangedSubview:view];
    self.headerView = view;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandButtonTapped:)];
    [self.headerView addGestureRecognizer:recognizer];
    self.tapRecognizer = recognizer;
    
    [self setupBodyLabel];
}

- (void)setupBodyLabel
{
    UITextView *bodyLabel = [[UITextView alloc] init];
    bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bodyLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    bodyLabel.hidden = !self.isExpanded;
    bodyLabel.scrollEnabled = NO;
    bodyLabel.editable = NO;
    bodyLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.stackView addArrangedSubview:bodyLabel];
    self.bodyLabel = bodyLabel;
    self.bodyLabel.text = self.body;
    self.bodyLabel.font = [UIFont cpLightFontWithSize:12 italic:NO];
    self.bodyLabel.textColor = [UIColor appSubCopyTextColor];
}

- (void)expandButtonTapped:(id)sender
{
    // TODO: put tap on the header or entire view?
    self.isExpanded = !self.isExpanded;
    
    // TODO: reverse direction of contract animation if possible
    CGAffineTransform targetTransform = self.isExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.expandButton.transform = targetTransform;
        self.bodyLabel.hidden = !self.isExpanded;
    } completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
