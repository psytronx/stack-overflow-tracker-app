//
//  pageTest.m
//  SO Tracker
//
//  Created by psytronx on 1/9/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SOTPage.h"

@interface pageTest : XCTestCase

@end

@implementation pageTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatInitializationWorks {
    
    NSDictionary *testPageData = @{
                                     @"_id": @"5691fc08bb1aab4c97a4c48f",
                                     @"path": @"/questions/12419205/nsdate-from-string",
                                     @"bestAnswerScore": @22,
                                     @"bestAnswerCreationDate": @"2012-09-14T06:34:04.000Z",
                                     @"bestAnswer": @"Test Answer",
                                     @"bestAnswerId": @12419256,
                                     @"tags": @[
                                             @"iphone",
                                             @"ios"
                                             ],
                                     @"creationDate": @"2012-09-14T06:29:41.000Z",
                                     @"question": @"Test Question",
                                     @"title": @"NSDate from string",
                                     @"url": @"http://stackoverflow.com/questions/12419205/nsdate-from-string",
                                     @"__v": @0,
                                     @"views": @1,
                                     @"lastViewed": @"2016-01-10T06:36:56.895Z"
                                    };
    
    SOTPage* page = [[SOTPage alloc] initWithDictionary:testPageData];
    
    XCTAssertEqualObjects(page.title, testPageData[@"title"], @"The title should be equal");
    XCTAssertEqual(page.views, [testPageData[@"views"] intValue], @"Page views should be equal");    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    XCTAssertEqualObjects(page.lastViewed, [dateFormatter dateFromString: testPageData[@"lastViewed"]], @"Last Viewed Date should be equal");
    XCTAssertEqualObjects(page.tags, testPageData[@"tags"], @"The tags should be equal");

}

@end
