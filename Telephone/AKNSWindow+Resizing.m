//
//  AKNSWindow+Resizing.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import "AKNSWindow+Resizing.h"


@implementation NSWindow (AKWindowResizingAdditions)

- (void)ak_resizeForContentViewSize:(NSSize)size animate:(BOOL)animate {
    CGFloat deltaWidth = size.width - self.contentView.frame.size.width;
    CGFloat deltaHeight = size.height - self.contentView.frame.size.height;
    NSRect frame = self.frame;
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    frame.size.width += deltaWidth;
    self.contentView = [[NSView alloc] initWithFrame:self.contentView.frame];
    [self setFrame:frame display:NO animate:animate];
}

@end
