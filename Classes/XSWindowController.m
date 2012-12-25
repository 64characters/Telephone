//
//  XSWindowController.m
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

#import "XSWindowController.h"
#import "XSViewController.h"

@interface XSWindowController () // class continuation allows us to redeclare the property as readwrite to we can privately use the setter
@property(nonatomic,copy) NSMutableArray *viewControllers;
@end

@implementation XSWindowController
@synthesize viewControllers = _viewControllers; // using synthesize will make our getter, but we create our own setter to keep mutability of the array

- (id)initWithWindowNibName:(NSString *)nibName;
{
	if (![super initWithWindowNibName:nibName])
		return nil;
	self.viewControllers = [NSMutableArray array];
	return self;
}

- (void)setViewControllers:(NSMutableArray *)newViewControllers;
{
	if (_viewControllers == newViewControllers)
		return;
	NSMutableArray *newViewControllersCopy = [newViewControllers mutableCopy];
	_viewControllers = newViewControllersCopy;
}

- (void)windowWillClose:(NSNotification *)notification;
{
	[self.viewControllers makeObjectsPerformSelector:@selector(removeObservations)];
}

- (NSUInteger)countOfViewControllers;
{
	return [self.viewControllers count];
}

- (XSViewController *)objectInViewControllersAtIndex:(NSUInteger)index;
{
	return [self.viewControllers objectAtIndex:index];
}

- (void)addViewController:(XSViewController *)viewController;
{
	[self.viewControllers insertObject:viewController atIndex:[self.viewControllers count]];
	[self patchResponderChain];
}

- (void)insertObject:(XSViewController *)viewController inViewControllersAtIndex:(NSUInteger)index;
{
	[self.viewControllers insertObject:viewController atIndex:index];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndexes:(NSIndexSet *)indexes;
{
	[self.viewControllers insertObjects:viewControllers atIndexes:indexes];
	[self patchResponderChain];
}

- (void)insertObjects:(NSArray *)viewControllers inViewControllersAtIndex:(NSUInteger)index;
{
	[self insertObjects:viewControllers inViewControllersAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

// ------------------------------------------
// It should be noted that if we remove an object from the view controllers array then the whole tree that descends from it will go too.
// ------------------------------------------
- (void)removeViewController:(XSViewController *)viewController;
{
	[self.viewControllers removeObject:viewController];
	[self patchResponderChain];
}

- (void)removeObjectFromViewControllersAtIndex:(NSUInteger)index;
{
	[self.viewControllers removeObjectAtIndex:index];
	[self patchResponderChain];
}

// ---------------------------------------------------
// This method creates an array containing all the view controllers, then adds them to the responder chain in sequence. The last view controller in the array has nextResponder == nil.
// ---------------------------------------------------
- (void)patchResponderChain;
{
	if ([self.viewControllers count] == 0) // we're being called by view controllers at the beginning of creating the tree, most likely load time and the root of the tree hasn't been added to our list of controllers.
		return;
	NSMutableArray *flatViewControllers = [NSMutableArray array];
	for (XSViewController *viewController in self.viewControllers) { // flatten the view controllers into an array
		[flatViewControllers addObject:viewController];
		[flatViewControllers addObjectsFromArray:[viewController descendants]];
	}
	[self setNextResponder:[flatViewControllers objectAtIndex:0]];
	NSUInteger index = 0;
	NSUInteger viewControllerCount = [flatViewControllers count] - 1;
	for (index = 0; index < viewControllerCount ; index++) { // set the next responder of each controller to the next, the last in the array has no next responder.
		[[flatViewControllers objectAtIndex:index] setNextResponder:[flatViewControllers objectAtIndex:index + 1]];
	}
}

@end
