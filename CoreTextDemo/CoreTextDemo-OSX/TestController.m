//
//  TestController.m
//  CoreTextDemo
//
//  Created by Chen Yonghui on 6/25/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TestController.h"
#import "TestCaseWindowController.h"

@interface TestController ()
@property (nonatomic, strong) TestCaseWindowController *tc;
@end

@implementation TestController
- (IBAction)didPressedTextButton:(id)sender {
    NSButton *button = sender;
    NSString *caseName = [self caseNameForButton:button];
    [self showTest:caseName];
}

- (NSString *)caseNameForButton:(NSButton *)button
{
    return button.title;
}

#pragma mark -
- (void)showTest:(NSString *)testName
{
    if (self.tc) {
        [self.tc close];
    }
    
    TestCaseWindowController *tc =[[TestCaseWindowController alloc] initWithWindowNibName:@"TestCaseWindowController"];
    tc.viewClass = NSClassFromString(testName);
    self.tc = tc;
    
    [tc showWindow:self];

}
@end
