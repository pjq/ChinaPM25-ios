//
//  FirstViewController.m
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import "FirstViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "City.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
NSMutableArray *listOfContacts;
NSMutableArray *filterList;
UIRefreshControl *refreshControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [progressView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    filterList = [[NSMutableArray alloc]init];
    [filterList addObject:@"上海"];
    [filterList addObject:@"深圳"];
    [filterList addObject:@"北京"];
    [filterList addObject:@"广州"];
    [filterList addObject:@"南昌"];
    [filterList addObject:@"新余"];
    [filterList addObject:@"苏州"];
    [filterList addObject:@"杭州"];
    
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
    progressView.hidden = NO;
    
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
        progressView.hidden = YES;
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated@%@", [self getDateString]]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
         refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated Error!!@%@", [self getDateString]]];
        [progressView stopAnimating];
        progressView.hidden = YES;
    }];
}

- (NSMutableArray*)reorderDataList:(NSMutableArray *) data{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    for(NSString *item in data){
        NSArray *listItems = [item componentsSeparatedByString:@"_"];
        if ([listItems count] == 2) {
            [newArray addObject:[self string2City:item]];
        }
    }
    
    [newArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        City *c1 = (City*)obj1;
        City *c2 = (City*)obj2;
        
        return (c1.pm25>c2.pm25);
    }];
    
    int i = 0;
    for(NSString *item in data){
        if ([self isFiltered:item]) {
            [newArray  insertObject:[self string2City:item] atIndex:i++];
        }
    }
   
    return newArray;
}

- (City*) string2City:(NSString*)cellValue {
    NSString *cityAll = [cellValue componentsSeparatedByString:@" "][0];
    int value = [cellValue componentsSeparatedByString:@" "][1].intValue;
    
    NSString *cityEn = [cityAll componentsSeparatedByString:@"_"][0];
    NSString *cityCn = [cityAll componentsSeparatedByString:@"_"][1];
    
    City *c = [[City alloc]init];
    c.enName = cityEn;
    c.cnName = cityCn;
    c.pm25 = value;
    
    return c;
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
    City *city= [listOfContacts objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@(%@) %d", city.cnName , city.enName, city.pm25];
    
    cell.textLabel.text = text;
    
    int pm25 = city.pm25;
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

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listOfContacts count];
}

- (NSString*) getDateString{
    NSDate *date = [NSDate date];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate: date];
//    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
//    NSLog(@"%@", localeDate);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSString *dateString = [format stringFromDate:date];
    
    return dateString;
}

//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [self getDateString];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    return @"Developed by http://pjq.me";
//}

@end
