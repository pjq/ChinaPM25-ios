//
//  CityTableViewController.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/11/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityTableViewController : UITableViewController
{
}

@property(nonatomic) UIActivityIndicatorView *progressView;
@property(nonatomic) NSMutableArray *originListOfContacts;
@property(nonatomic) NSMutableArray *listOfContacts;
@property(nonatomic) NSMutableArray *selectedCityList;
@property(nonatomic) UIRefreshControl *refreshCtl;
@property(nonatomic) int avg;
@property(nonatomic) UIBarButtonItem *done;
@property(nonatomic) UIBarButtonItem *edit;
//@property(nonatomic) NSString *CellIndentifier;
@property(nonatomic)BOOL isSettingMode;

@end
