//
//  FirstViewController.m
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import "CityListViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "City.h"

@interface CityListViewController ()

@end

@implementation CityListViewController
NSMutableArray *listOfContacts;
NSMutableArray *filterList;
UIRefreshControl *refreshControl;
int avg = 0;
UIBarButtonItem *save;
UIBarButtonItem *edit;
static NSString *CellIndentifier = @"CityCell";

BOOL isSettingMode = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    progressView = [[UIActivityIndicatorView alloc] init];
    [progressView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
//    [self.navigationController.navigationBar addSubview:progressView];
    edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickSettingButton:)];
    save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(clickSettingButton:)];
    self.navigationItem.rightBarButtonItem = edit;
    // Do any additional setup after loading the view, typically from a nib.
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

- (void) clickSettingButton:(id *)sender{
    if (isSettingMode) {
        self.navigationItem.rightBarButtonItem =  edit;
    } else {
         self.navigationItem.rightBarButtonItem = save;
    }
    
    isSettingMode = !isSettingMode;
    
//    tableView.dataSource = self;
    [tableView beginUpdates];
    [tableView reloadData];
    [tableView endUpdates];
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
//        tableView.dataSource = self;
        NSLog(@"list count %ld", listOfContacts.count);
        //        [tableView beginUpdates];
        [tableView reloadData];
        //        [tableView endUpdates];
        [progressView stopAnimating];
        progressView.hidden = YES;
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated@%@", [self getDateString]]];
        NSString* titleText = [NSString stringWithFormat:@"%@(avg. %d)", @"China PM2.5", avg];
        
        [self setTitle: titleText];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
         refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated Error!!@%@", [self getDateString]]];
        [progressView stopAnimating];
        progressView.hidden = YES;
    }];
}

- (NSMutableArray*)reorderDataList:(NSMutableArray *) data{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    int total = 0;
    int count = 0;
    for(NSString *item in data){
        NSArray *listItems = [item componentsSeparatedByString:@"_"];
        if ([listItems count] == 2) {
            City *cc = [self string2City:item];
            [newArray addObject:cc];
            count++;
            total+=cc.pm25;
        }
    }
    
    avg = total/count;
    
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

- (BOOL) isSelectedCity:(City *)city
{
    for (NSString *f in filterList){
        if ([city.cnName isEqualToString:f] || [city.enName isEqualToString:f]){
            return TRUE;
        }
    }
    
    return FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (UITableViewCell *) tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:CellIndentifier];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
    
    UILabel *title =[cell viewWithTag:11];
    UILabel *subTitle =[cell viewWithTag:12];
    UILabel *detail =[cell viewWithTag:13];
    UISwitch *checkSwitch = [cell viewWithTag:14];
 
    City *city= [listOfContacts objectAtIndex:indexPath.row];
    
    title.text = city.cnName;
    subTitle.text = city.enName;
    detail.text = [NSString stringWithFormat:@"%d", city.pm25];
    
    if (isSettingMode) {
        detail.hidden = YES;
        checkSwitch.hidden = NO;
        BOOL selected = [self isSelectedCity:city];
        // checkSwitch.on = selected;
        // [checkSwitch setOn:selected animated:YES];
    }else{
        detail.hidden = NO;
        checkSwitch.hidden = YES;
    }
    
    checkSwitch.tag = indexPath.row;
//    [checkSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
//    
    
    int pm25 = city.pm25;
    if (pm25>=200) {
        detail.textColor = [UIColor purpleColor];
    }
    else if (pm25>=150) {
        detail.textColor = [UIColor redColor];
    }
    else if (pm25>=100) {
        detail.textColor = [UIColor blueColor];
    } else {
        detail.textColor = [UIColor greenColor];
    }
    
    return cell;
}

- (void) changeSwitch:(UISwitch *) sender{
    NSInteger  index = sender.tag;
    City *city = [listOfContacts objectAtIndex:index];
    
    [self updateFilterList:city selected:sender.on];
}

- (void) updateFilterList:(City *) city  selected:(BOOL) selected {
    if ([self isSelectedCity:city]) {
        if (selected) {
            
        } else {
            [filterList removeObject:city.cnName];
        }
        
    } else {
        if (selected) {
            [filterList addObject:city.cnName];
        } else {
            
        }
    }
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
