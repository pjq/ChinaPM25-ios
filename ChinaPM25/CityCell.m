//
//  CityCell.m
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/11/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import "CityCell.h"

@implementation CityCell
@synthesize cnName;
@synthesize enName;
@synthesize pm;
@synthesize uiSwitch;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCity:(City *)city{
    
}

@end
