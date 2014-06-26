//
//  TestCaseWindowController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 6/25/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TestCaseWindowController.h"
#import "CoreTextView.h"
@interface TestCaseWindowController ()

@end

@implementation TestCaseWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSView *contentView = self.window.contentView;
    NSView *testView = [[self.viewClass alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:testView];
}

@end
