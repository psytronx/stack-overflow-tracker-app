//
//  CustomActivityIndicatorView.m
//  SO Tracker
//
//  Created by psytronx on 1/15/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import "CustomActivityIndicatorView.h"

@interface CustomActivityIndicatorView()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation CustomActivityIndicatorView

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup {
    
    // Setup background window
    self.layer.cornerRadius = 12;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    self.hidden = YES;
    
    // Setup activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    self.activityIndicator.frame = CGRectMake(self.bounds.size.width/2, self.bounds.size.height/2, 36, 36);
    [self.activityIndicator startAnimating];
    [self addSubview:self.activityIndicator];
    
    // Setup label
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = self.text;
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    
    // Autolayout
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerActivityIndicatorXConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                                                                         multiplier:1.f constant:0.f];
    NSLayoutConstraint *centerActivityIndicatorYConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                                          attribute:NSLayoutAttributeCenterY
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self
                                                                                          attribute:NSLayoutAttributeCenterY
                                                                                         multiplier:1.f constant:0.f];
    
    [self addConstraints:@[centerActivityIndicatorXConstraint, centerActivityIndicatorYConstraint]];
//    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_textLabel, _activityIndicator);
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_activityIndicator]|" options:kNilOptions metrics:nil views:viewDictionary]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_activityIndicator]|" options:kNilOptions metrics:nil views:viewDictionary]];
//    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
