//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTile.h"
#import "AttributedMarkdown/markdown_lib.h"
#import "AttributedMarkdown/markdown_peg.h"
#import "CPTileTextFormatter.h"
@import UIKit;

@implementation CPTile {

}

- (NSAttributedString *)parsedBody {
    if (!_parsedBody) {
        _parsedBody = [[CPTileTextFormatter instance] formatTileText:self.body forPet:nil];
    }

    return _parsedBody;
}

- (void)setBody:(NSString *)body {
    self.parsedBody = nil;
    _body = body;
}
@end