//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTileViewCell.h"
#import "CPTile.h"

@interface CPTileViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@end

@implementation CPTileViewCell {
}

- (void)setTile:(CPTile *)tile {
    self.titleLabel.text = tile.title;
    self.bodyTextView.attributedText = tile.parsedBody;
    self.imageView.image = tile.image;
}

- (void)awakeFromNib
{
    for (UIView *view in @[self.titleLabel, self.bodyTextView, self.imageView]) {
        view.layer.borderColor = [[UIColor redColor] CGColor];
        view.layer.borderWidth = 3;
    }
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    layoutAttributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    return layoutAttributes;
}
@end