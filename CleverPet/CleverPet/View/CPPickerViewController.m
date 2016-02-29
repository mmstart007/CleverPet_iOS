//
//  CPPickerViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPickerViewController.h"
#import "CPSimpleTableViewCell.h"
#import "CPGenderUtils.h"

@interface CPPickerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *separator;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CPPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.separator.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"CPSimpleTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.view.autoresizingMask = UIViewAutoresizingNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupForPickingGender
{
    self.dataArray = @[NSLocalizedString(@"Male", nil), NSLocalizedString(@"Female", nil)];
}

- (void)setupForPickingNeuteredWithGender:(NSString *)gender
{
    self.dataArray = @[[CPGenderUtils stringForAlteredState:kGenderNeutralAltered withGender:gender], [CPGenderUtils stringForAlteredState:kGenderNeutralUnaltered withGender:gender], [CPGenderUtils stringForAlteredState:kGenderNeutralUnspecified withGender:gender]];
}

- (void)updateHeightWithMaximum:(CGFloat)maxHeight
{
    // Update our frame size with the lower of our table content size, or the provided max height
    CGRect currentBounds = self.view.bounds;
    currentBounds.size.height = MIN(self.tableView.contentSize.height, maxHeight);
    self.view.bounds = currentBounds;
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
