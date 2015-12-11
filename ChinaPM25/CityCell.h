//
//  CityCell.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/11/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

@interface CityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cnName;
@property (weak, nonatomic) IBOutlet UILabel *enName;
@property (weak, nonatomic) IBOutlet UILabel *pm;
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;

- (void)setCity:(City *)city;
@end
