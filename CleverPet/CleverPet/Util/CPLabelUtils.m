//
//  CPLabelUtils.m
//  CleverPet
//
//  Created by Daryl at Finger Foods on 2016-02-24.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

@import UIKit;

void ApplyFontAndColorToLabels(UIFont *font, UIColor *color, NSArray<UILabel *> *labels) {
    for (UILabel *label in labels) {
        label.font = font;
        label.textColor = color;
    }
}