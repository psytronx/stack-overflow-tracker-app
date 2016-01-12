//
//  PageCell.m
//  SO Tracker
//
//  Created by psytronx on 1/5/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import "PageCell.h"
#import "SOTPage.h"

@interface PageCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *views;
@property (weak, nonatomic) IBOutlet UILabel *lastDateViewed;
@end

@implementation PageCell

+ (CGFloat)getCellHeightForPage:(SOTPage *)page width:(CGFloat)width {
    
    // TODO - Make this work!
    
    PageCell *dummyCell = [[[NSBundle mainBundle] loadNibNamed:@"PageCell" owner:self options:nil] objectAtIndex:0];
    dummyCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX); // Maximize height to get it out of the way.
    dummyCell.page = page;
    [dummyCell layoutSubviews];
    
    return CGRectGetMaxY(dummyCell.lastDateViewed.frame) + 20; // Bottom of the bottom-most view, plus some padding, is the height we want.
}

- (void)awakeFromNib {
    // Initialization code
    
    self.title.text = @"";
    self.lastDateViewed.text = @"";
    self.views.text = @"";

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    self.title.preferredMaxLayoutWidth = mainScreen.bounds.size.width - 40; // Leave room for disclosure indicator
    
    // Hide the line between cells
//    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2.0, 0, CGRectGetWidth(self.bounds)/2.0);
    
    
    [super layoutSubviews];

}

- (void)setPage:(SOTPage *)page {
    
    _page = page;
    self.title.text = page.title;
    self.views.text = [NSString stringWithFormat:@"%ld", page.views];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM DD"];
    self.lastDateViewed.text = [dateFormatter stringFromDate:page.lastViewed];
    
}

@end
