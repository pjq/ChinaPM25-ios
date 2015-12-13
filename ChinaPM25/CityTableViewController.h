//
//  CityTableViewController.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/11/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface CityTableViewController : UITableViewController
{
}

@property(nonatomic) UIActivityIndicatorView *progressView;
@property(nonatomic) NSMutableArray *originListOfContacts;
@property(nonatomic) NSMutableArray *currentCityList;
@property(nonatomic) NSMutableArray *selectedCityList;
@property(nonatomic) UIRefreshControl *refreshCtl;
@property(nonatomic) int avg;
@property(nonatomic) UIBarButtonItem *done;
@property(nonatomic) UIBarButtonItem *edit;
//@property(nonatomic) NSString *CellIndentifier;
@property(nonatomic)BOOL isSettingMode;

@end
