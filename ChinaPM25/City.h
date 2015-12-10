//
//  City.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/10/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property (nonatomic) int pm25;
@property (nonatomic) int index;
@property (nonatomic) NSString *cnName;
@property (nonatomic) NSString *enName;

@end
