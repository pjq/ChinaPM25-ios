//
//  FirstViewController.m
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import "FirstViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface FirstViewController ()

@end

@implementation FirstViewController
NSMutableArray *listOfContacts;
NSMutableArray *filterList;
UIRefreshControl *refreshControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [progressView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    filterList = [[NSMutableArray alloc]init];
    [filterList addObject:@"shanghai"];
    [filterList addObject:@"shengzhen"];
    [filterList addObject:@"beijing"];
    [filterList addObject:@"nanchang"];
    [filterList addObject:@"xinyu"];
    
    listOfContacts = [[NSMutableArray alloc]init];
    
    //    for (int i = 0; i< 10; i++) {
    //        [listOfContacts addObject:[NSString stringWithFormat:@"Contact%d", i]];
    //    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    
    [tableView addSubview:refreshControl];
    
//    [refreshControl beginRefreshing];
    
    [self getInfoFromServer];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    [refreshControl endRefreshing];
    [self getInfoFromServer];
}

- (void)getInfoFromServer{
    [progressView startAnimating];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://ef.pjq.me/download/pm25/all_city/pm25_all.txt" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@", string);
        
        NSMutableArray * fileLines = [[NSMutableArray alloc] initWithArray:[string componentsSeparatedByString:@"\n"] copyItems: YES];
        listOfContacts = [self reorderDataList:fileLines];
        tableView.dataSource = self;
        NSLog(@"list count %ld", listOfContacts.count);
        //        [tableView beginUpdates];
        [tableView reloadData];
        //        [tableView endUpdates];
        [progressView stopAnimating];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated@%@", [self getDateString]]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
         refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated Error!!@%@", [self getDateString]]];
        [progressView stopAnimating];
    }];
}

- (NSMutableArray*)reorderDataList:(NSMutableArray *) data{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for(NSString *item in data){
        if ([self isFiltered:item]) {
            [newArray addObject:item];
        }
    }
    for(NSString *item in data){
        NSArray *listItems = [item componentsSeparatedByString:@"_"];
        if ([listItems count] == 2) {
            [newArray addObject:item];
        }
    }
    
    return newArray;
}

- (BOOL) isFiltered:(NSString *)item
{
    for (NSString *f in filterList){
        if ([item containsString:f]){
            return TRUE;
        }
    }
    
    return FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIndentifier = @"Contact";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
    NSString *cellValue = [listOfContacts objectAtIndex:indexPath.row];
    
    if([cellValue componentsSeparatedByString:@" "].count != 2){
        cell.textLabel.text = cellValue;
    }else{
        NSString *cityAll = [cellValue componentsSeparatedByString:@" "][0];
        NSString *value = [cellValue componentsSeparatedByString:@" "][1];
        
        NSString *cityEn = [cityAll componentsSeparatedByString:@"_"][0];
        NSString *cityCn = [cityAll componentsSeparatedByString:@"_"][1];
        
        NSString *text = [NSString stringWithFormat:@"%@(%@) %@", cityCn, cityEn, value];
        
        cell.textLabel.text = text;
        
        int pm25 = [value intValue];
        if (pm25>=200) {
            cell.textLabel.textColor = [UIColor purpleColor];
        }
        else if (pm25>=150) {
            cell.textLabel.textColor = [UIColor redColor];
        }
        else if (pm25>=100) {
            cell.textLabel.textColor = [UIColor blueColor];
        }else {
            cell.textLabel.textColor = [UIColor greenColor];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listOfContacts count];
}

- (NSString*) getDateString{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSLog(@"%@", localeDate);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSString *dateString = [format stringFromDate:localeDate];
    
    return dateString;
}

//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [self getDateString];
//}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"Developed by http://pjq.me";
}

@end
