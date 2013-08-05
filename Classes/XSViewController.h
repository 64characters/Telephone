//
//  XSViewController.h
//  View Controllers
//
//  Created by Jonathan Dann and Cathy Shive on 14/04/2008.
//
// Copyright (c) 2008 Jonathan Dann and Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "View Conrtollers" by Jonathan Dann and Cathy Shive" will do.

#import <Cocoa/Cocoa.h>

// XS for Xtra-Special!

@class XSWindowController;
@interface XSViewController : NSViewController {
@private
	XSViewController *__weak _parent;
	XSWindowController *__weak _windowController;
	NSMutableArray *_children;
}

@property(weak) XSViewController *parent;
@property(weak) XSWindowController *windowController;
@property(readonly,copy) NSMutableArray *children; // there's no mutableCopy keyword so this will be @synthesized in the implementation to get the default getter, but we'll write our own setter, otherwise mutability is lost

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(XSWindowController *)windowController;

- (NSUInteger)countOfChildren;
- (XSViewController *)objectInChildrenAtIndex:(NSUInteger)index;

- (void)addChild:(XSViewController *)viewController;
- (void)insertObject:(XSViewController *)viewController inChildrenAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)insertObjects:(NSArray *)viewControllers inChildrenAtIndex:(NSUInteger)index;

- (void)removeChild:(XSViewController *)viewController;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

- (XSViewController *)rootController;
- (NSArray *)descendants;
- (void)removeObservations;

@end
