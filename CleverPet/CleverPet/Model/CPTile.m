//
// Created by Daryl at Finger Foods on 2016-02-15.
// Copyright (c) 2016 CleverPet, Inc. All rights reserved.
//

#import "CPTile.h"
#import "AttributedMarkdown/markdown_lib.h"
#import "AttributedMarkdown/markdown_peg.h"
#import "CPMarkdownAttributedString.h"
@import UIKit;

@implementation CPTile {

}



- (NSAttributedString *)parsedBody {
    if (!_parsedBody) {
        _parsedBody = [CPMarkdownAttributedString attributedStringFromMarkdownString:self.body];
    }

    return _parsedBody;
}

- (void)setBody:(NSString *)body {
    self.parsedBody = nil;
    _body = body;
}
@end