//
//  CPFAQViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPFAQViewController.h"

@interface CPFAQViewController ()

@property (nonatomic, strong) NSArray *backingArray;
@property (nonatomic, strong) NSMutableSet *expandedIndexes;

@end

@interface CPFAQTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandImage;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIView *pseudoSeparator;

- (void)setupWithTitle:(NSString*)title body:(NSString*)body expanded:(BOOL)expanded;

@end

@implementation CPFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backingArray = @[@{@"title":@"This is a variable amount of header text", @"body":@"This is a variable amount of body text"}, @{@"title":@"This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text", @"body":@"This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text"}, @{@"title":@"This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text This is a variable amount of header text", @"body":@"This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text This is a variable amount of body text"}];
    self.expandedIndexes = [NSMutableSet set];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.estimatedRowHeight = 70.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleCellAtIndex:(NSInteger)index
{
    NSNumber *indexObject = @(index);
    if ([self.expandedIndexes containsObject:indexObject]) {
        [self.expandedIndexes removeObject:indexObject];
    } else {
        [self.expandedIndexes addObject:indexObject];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.backingArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPFAQTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *info = self.backingArray[indexPath.row];
    [cell setupWithTitle:info[@"title"] body:info[@"body"] expanded:[self.expandedIndexes containsObject:@(indexPath.row)]];
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCellAtIndex:indexPath.row];
}

@end

@implementation CPFAQTableCell

- (void)awakeFromNib
{
    
}

- (void)setupWithTitle:(NSString *)title body:(NSString *)body expanded:(BOOL)expanded
{
    self.headerLabel.text = title;
    self.bodyLabel.text = body;
    self.bodyLabel.hidden = !expanded;
}

@end
