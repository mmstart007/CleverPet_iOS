//
//  CPSettingsViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-18.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPSettingsViewController.h"

NSUInteger const kDeviceSection = 0;
NSUInteger const kHelpSection = 1;
NSUInteger const kAccountSection = 2;

@interface CPSettingsBasicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@interface CPSettingsHubStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorDot;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (void)updateWithHubStatus;

@end

@interface CPSettingsViewController ()

@property (weak, nonatomic) IBOutlet CPSettingsHubStatusCell *hubCell;
@property (weak, nonatomic) UIBarButtonItem *pseudoBackButton;

@end

@implementation CPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.separatorColor = [UIColor appBackgroundColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // TODO: button image
    [button setTitle:@"Settings" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    self.pseudoBackButton = barButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (void)menuButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: check hub state
    if (section == kHelpSection && YES) {
        return 2;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDeviceSection) {
        return 70.f;
    }
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case kDeviceSection:
        {
            title = NSLocalizedString(@"Device", @"Settings device section header");
            break;
        }
        case kHelpSection:
        {
            title = NSLocalizedString(@"Help", @"Settings help section header");
            break;
        }
        case kAccountSection:
        {
            title = NSLocalizedString(@"Account", @"Settings account section header");
            break;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50.f)];
    headerView.backgroundColor = [UIColor appBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    titleLabel.textColor = [UIColor appTitleTextColor];
    [headerView addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(15.f, 0.f, titleLabel.bounds.size.width, headerView.bounds.size.height);
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // TODO: Check hub status
    if (indexPath.section == kHelpSection && NO) {
        // Offset our index path to account for the hidden chat with us cell
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:newIndexPath];
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Basic Cell

@implementation CPSettingsBasicCell

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    self.separator.backgroundColor = [UIColor appBackgroundColor];
    // TODO: disclosure indicator image
}

- (void)setupWithTitle:(NSString*)title
{
    self.titleLabel.text = title;
}

@end

#pragma mark - Hub Status Cell

@implementation CPSettingsHubStatusCell

- (void)awakeFromNib
{
    self.indicatorDot.layer.cornerRadius = self.indicatorDot.bounds.size.width*.5f;
    self.titleLabel.font = [UIFont cpLightFontWithSize:kTableCellTitleSize italic:NO];
    self.titleLabel.textColor = [UIColor appTitleTextColor];
    self.statusLabel.font = [UIFont cpLightFontWithSize:kTableCellSubTextSize italic:NO];
    self.statusLabel.textColor = [UIColor appTitleTextColor];
    // TODO: disclosure indicator image
}

- (void)updateWithHubStatus
{
    // TODO: Update with hub status once we're connecting. Dot color, status text, hide/show disclosure indicator
}

@end
