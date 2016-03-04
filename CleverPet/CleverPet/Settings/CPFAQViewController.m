//
//  CPFAQViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPFAQViewController.h"
#import "CPFAQView.h"
#import "CHCSVParser.h"

@interface CPFAQViewController ()

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CPFAQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *faqs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"faqs" withExtension:@"json"]] options:kNilOptions error:nil];
    
    // TODO: make sure the parsing is still valid if faqs are updated is updated
    // We have some section headers, and some bogus empty spaces, so we need to convert this to usable data.
    for (NSDictionary *dict in faqs) {
        NSString *title, *body;
        if ([dict[@"Question"] isKindOfClass:[NSString class]]) {
            title = dict[@"Question"];
        }
        if ([dict[@"Answer"] isKindOfClass:[NSString class]]) {
            body = dict[@"Answer"];
        }
        
        if (!title && !body) {
            // If we have no title and no body, this was an extra line or something in the csv, so ignore it
            continue;
        }
        
        if (!body) {
            // This is a section header
            [self.stackView addArrangedSubview:[self headerViewWithTitle:title]];
        } else {
            // Question and answer
            [self.stackView addArrangedSubview:[[CPFAQView alloc] initWithTitle:title andBody:body]];
        }
    }
    
    self.view.backgroundColor = [UIColor appBackgroundColor];
}

- (UIView *)headerViewWithTitle:(NSString*)title
{
    // TODO: maybe add constraints since this probably falls apart when rotated
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    [view addSubview:label];
    [label setFont:[UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO]];
    [view setBackgroundColor:[UIColor appBackgroundColor]];
    [label setTextColor:[UIColor appTitleTextColor]];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    NSDictionary *viewsDict = @{@"label":label};
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:kNilOptions metrics:nil views:viewsDict];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:kNilOptions metrics:nil views:viewsDict];
    [view addConstraints:verticalConstraints];
    [view addConstraints:horizontalConstraints];
    
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
