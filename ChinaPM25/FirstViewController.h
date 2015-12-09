//
//  FirstViewController.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *progressView;
    __weak IBOutlet UITextField *titleBarText;
    __weak IBOutlet UITableView *tableView;
}


@end

