//
//  PageCell.h
//  SO Tracker
//
//  Created by psytronx on 1/5/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SOTPage;

@interface PageCell : UITableViewCell
@property (nonatomic, strong) SOTPage *page;

+ (CGFloat)getCellHeightForPage: (SOTPage *)page width:(CGFloat)width;

@end
