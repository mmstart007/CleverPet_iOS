//
//  CPFAQViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPFAQViewController.h"
#import "CPFAQView.h"

@interface CPFAQViewController ()

@property (nonatomic, strong) NSArray *backingArray;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CPFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: get this from not here
    self.backingArray = @[@{@"title":@"This is a variable amount of header text", @"body":@"This is a variable amount of body text"}, @{@"title":@"This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text", @"body":@"This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text"}, @{@"title":@"This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text", @"body":@"This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text"}];
    
    self.view.backgroundColor = [UIColor appBackgroundColor];
    for (NSDictionary *info in self.backingArray) {
        CPFAQView *faqView = [[CPFAQView alloc] initWithTitle:info[@"title"] andBody:info[@"body"]];
        [self.stackView addArrangedSubview:faqView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
