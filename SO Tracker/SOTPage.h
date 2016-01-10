//
//  page.h
//  SO Tracker
//
//  Created by psytronx on 1/9/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOTPage : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *lastViewed;
@property (nonatomic, assign) NSInteger views;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSArray *tags;

- (instancetype) initWithDictionary:(NSDictionary *)pageDict;

@end
