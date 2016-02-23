//
//  CPPickerViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPGenderPickerViewController.h"
#import "CPSimpleTableViewCell.h"

@interface CPGenderPickerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CPGenderPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = @[NSLocalizedString(@"Male", nil), NSLocalizedString(@"Female", nil)];
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"CPSimpleTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPSimpleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setupWithString:self.dataArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate pickerViewController:self selectedString:self.dataArray[indexPath.row]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end