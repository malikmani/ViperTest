//
//  ZTMainViewTests.m
//  ZazoTest
//
//  Created by Usman Awan on 11/14/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ZTMainViewController.h"

@interface ZTMainViewTests : XCTestCase

@property (nonatomic, strong)   ZTMainViewController*  view;

@end

@implementation ZTMainViewTests

- (void)setUp {
    [super setUp];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.view = [storyboard instantiateViewControllerWithIdentifier:@"ZTMainViewController"];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testShowingAlert
{    
    [self.view presentingAlertWithTitle:@"Zazo Test" andMessage:@"Test Message"];
    
    XCTAssert(TRUE,@"passed");
}

- (void)testLoadVideoEntries
{
    [self.view loadVideoEntries];
    
    XCTAssert(TRUE,@"passed");
}

- (void)testRemoveVideoEntries
{
    [self.view removeVideoEntries];
    
    XCTAssert(TRUE,@"passed");
    
}

@end
