//
//  page.m
//  SO Tracker
//
//  Created by psytronx on 1/9/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import "SOTPage.h"

@implementation SOTPage

- (instancetype) initWithDictionary:(NSDictionary *)pageDict {
    
    self = [super init];
    if (self) {
        self.title = pageDict[@"title"];
        self.views = [pageDict[@"views"] intValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        self.lastViewed = [dateFormatter dateFromString: pageDict[@"lastViewed"]];
        self.tags = pageDict[@"tags"];
        self.path = pageDict[@"path"];
    }
    return self;
    
}

// To do - implement copyWithZone:

@end
