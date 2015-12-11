//
//  FirstViewController.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIActivityIndicatorView *progressView;
    __weak IBOutlet UITableView *tableView;
    
}



@end

