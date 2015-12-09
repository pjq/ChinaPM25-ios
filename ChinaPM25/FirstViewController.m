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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    filterList = [[NSMutableArray alloc]init];
    [filterList addObject:@"shanghai"];
    [filterList addObject:@"shengzhen"];
    [filterList addObject:@"beijing"];
    [filterList addObject:@"nanchang"];
    [filterList addObject:@"xinyu"];
    
    listOfContacts = [[NSMutableArray alloc]init];
    
    for (int i = 0; i< 10; i++) {
        [listOfContacts addObject:[NSString stringWithFormat:@"Contact%d", i]];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    
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
        NSLog(@"%@", string);
        
        NSMutableArray * fileLines = [[NSMutableArray alloc] initWithArray:[string componentsSeparatedByString:@"\n"] copyItems: YES];
        listOfContacts = [self reorderDataList:fileLines];
        tableView.dataSource = self;
        NSLog(@"list count %ld", listOfContacts.count);
//        [tableView beginUpdates];
        [tableView reloadData];
//        [tableView endUpdates];
        [progressView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
    
    [newArray addObjectsFromArray:data];
    
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
    
    cell.textLabel.text = cellValue;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listOfContacts count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSLog(@"%@", localeDate);
    
    return [NSString stringWithFormat:@"%@", localeDate];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"Developed by http://pjq.me";
}

@end
