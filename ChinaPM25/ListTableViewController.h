//
//  ListTableViewController.h
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UITableViewController
{
    IBOutlet UIActivityIndicatorView *progressView;
    IBOutlet UITextField *titleBarText;
    IBOutlet UITableView *tableView;
//    IBOutlet UITableView *tableView;
}
@end
