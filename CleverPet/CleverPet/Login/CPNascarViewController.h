//
//  CPNascarViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-15.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPNascarViewController : UIViewController

@property (nonatomic, assign) BOOL isAutoLogin;

- (void)autoLoginFailed;

@end
