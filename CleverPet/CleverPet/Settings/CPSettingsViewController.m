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

@interface CPSettingsViewController ()


@end

@interface CPSettingsBasicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@interface CPSettingsHubStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorDot;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (void)updateWithHubStatus;

@end

@implementation CPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: check hub state
    if (section == kHelpSection) {
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
    titleLabel.textColor = [UIColor appSignUpHeaderTextColor];
    [headerView addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(15.f, 0.f, titleLabel.bounds.size.width, headerView.bounds.size.height);
    return headerView;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Hide separator if it's the last row in the section
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.size.width);
    } else {
        cell.separatorInset = UIEdgeInsetsZero;
    }
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
    self.titleLabel.textColor = [UIColor appSignUpHeaderTextColor];
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
    self.titleLabel.textColor = [UIColor appSignUpHeaderTextColor];
    self.statusLabel.font = [UIFont cpLightFontWithSize:kTableCellSubTextSize italic:NO];
    self.statusLabel.textColor = [UIColor appSignUpHeaderTextColor];
    // TODO: disclosure indicator image
}

- (void)updateWithHubStatus
{
    // TODO: Update with hub status once we're connecting. Dot color, status text, hide/show disclosure indicator
}

@end
