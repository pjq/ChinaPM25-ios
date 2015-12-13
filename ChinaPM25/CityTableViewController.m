//
//  FirstViewController.m
//  ChinaPM25
//
//  Created by Jianqing Peng on 12/9/15.
//  Copyright © 2015 Jianqing Peng. All rights reserved.
//

#import "CityTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "City.h"
#import "CityCell.h"

@interface CityTableViewController ()

@end

@implementation CityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSettingMode = NO;
    
    self.progressView = [[UIActivityIndicatorView alloc] init];
    [self.progressView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    //    [self.navigationController.navigationBar addSubview:progressView];
    self.edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickSettingButton:)];
    self.done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickSettingButton:)];
    self.navigationItem.rightBarButtonItem = self.edit;
    // Do any additional setup after loading the view, typically from a nib.
    self.currentCityList = [[NSMutableArray alloc]init];
    
    self.selectedCityList = [self getSelectedCity];
    if (nil == self.selectedCityList || self.selectedCityList.count == 0) {
        self.selectedCityList = [[NSMutableArray alloc]init];
        [self.selectedCityList addObject:@"上海"];
        [self.selectedCityList addObject:@"深圳"];
        [self.selectedCityList addObject:@"北京"];
        [self.selectedCityList addObject:@"广州"];
        [self.selectedCityList addObject:@"南昌"];
        [self.selectedCityList addObject:@"新余"];
        [self.selectedCityList addObject:@"苏州"];
        [self.selectedCityList addObject:@"杭州"];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    
    [self.tableView addSubview:self.refreshControl];
    
    //    [refreshControl beginRefreshing];
    
    [self getInfoFromServer];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self saveSelectedCity:self.selectedCityList];
}

- (NSMutableArray *) getSelectedCity {
    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
    return [NSMutableArray arrayWithArray:[data valueForKey:@"selected_city"]];
}

- (void) saveSelectedCity:(NSMutableArray *) selectedCity {
    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
    [data setValue:selectedCity forKey:@"selected_city"];
}

- (void) clickSettingButton:(id *)sender{
    if (self.isSettingMode) {
        self.navigationItem.rightBarButtonItem =  self.edit;
        
        self.currentCityList = [self mergeCityList:self.originListOfContacts selectedCityList:self.selectedCityList];
        
        [self saveSelectedCity:self.selectedCityList];
    } else {
        self.navigationItem.rightBarButtonItem = self.done;
    }
    
    self.isSettingMode = !self.isSettingMode;
    
    [self.tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    [refreshControl endRefreshing];
    [self getInfoFromServer];
}

- (void)getInfoFromServer{
    [self.progressView startAnimating];
    self.progressView.hidden = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://ef.pjq.me/download/pm25/all_city/pm25_all.txt" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@", string);
        
        NSMutableArray * fileLines = [[NSMutableArray alloc] initWithArray:[string componentsSeparatedByString:@"\n"] copyItems: YES];
        self.originListOfContacts = [self generateOriginCityList:fileLines];
        self.currentCityList = [self mergeCityList:self.originListOfContacts selectedCityList:self.selectedCityList];
        
        //        tableView.dataSource = self;
        NSLog(@"city list count %d", self.currentCityList.count);
        //        [tableView beginUpdates];
        [self.tableView reloadData];
        //        [tableView endUpdates];
        [self.progressView stopAnimating];
        self.progressView.hidden = YES;
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated@%@", [self getDateString]]];
        NSString* titleText = [NSString stringWithFormat:@"%@(avg. %d)", @"China PM2.5", self.avg];
        
        [self setTitle: titleText];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:  [NSString stringWithFormat:@"Updated Error!!@%@", [self getDateString]]];
        [self.progressView stopAnimating];
        self.progressView.hidden = YES;
    }];
}
int total = 0;
int count = 0;
- (NSMutableArray*)generateOriginCityList :(NSMutableArray *) data{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    total = 0;
    count = 0;
    for(NSString *item in data){
        NSArray *listItems = [item componentsSeparatedByString:@"_"];
        if ([listItems count] == 2) {
            City *cc = [self string2City:item];
            [newArray addObject:cc];
            count++;
            total+=cc.pm25;
        }
    }
    
    return newArray;
}

- (NSMutableArray *) mergeCityList:(NSMutableArray *) cityList selectedCityList:(NSMutableArray *)selectedList {
    self.avg = total/count;
    
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    [newArray addObjectsFromArray:cityList];
    
    [newArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        City *c1 = (City*)obj1;
        City *c2 = (City*)obj2;
        
        return (c1.pm25>c2.pm25);
    }];
    
    int i = 0;
    for(NSString *item in selectedList){
        City *city = [self getCityByName:item inCityList:newArray];
        
        if (city) {
            [newArray  insertObject:city atIndex:i++];
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
    for (NSString *f in self.selectedCityList){
        if ([item containsString:f]){
            return TRUE;
        }
    }
    
    return FALSE;
}

- (City *) getCityByName:(NSString *)city inCityList:(NSMutableArray *) cityList
{
    for (City *f in cityList){
        if ([f.cnName isEqualToString:city] || [f.enName isEqualToString:city]){
            return f;
        }
    }
    
    return nil;
}

- (BOOL) isSelectedCity:(City *)city
{
    for (NSString *f in self.selectedCityList){
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
    static BOOL nibRegistered = NO;
    static NSString *CellIndentifier = @"CustomCellIdentifier";
    
    if (!nibRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CityCellUI" bundle:nil];
        
        [tableview registerNib:nib forCellReuseIdentifier:CellIndentifier];
        nibRegistered = YES;
    }
    
    CityCell *cell = [tableview dequeueReusableCellWithIdentifier:CellIndentifier];
    
    if (cell == nil) {
        cell = [[CityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier];
    }
//    
//    UILabel *title =[cell viewWithTag:11];
//    UILabel *subTitle =[cell viewWithTag:12];
//    UILabel *detail =[cell viewWithTag:13];
//    UISwitch *checkSwitch = [cell viewWithTag:14];
//    
    City *city= [self.currentCityList objectAtIndex:indexPath.row];
    
//    title.text = city.cnName;
//    subTitle.text = city.enName;
//    detail.text = [NSString stringWithFormat:@"%d", city.pm25];
//
    
    cell.cnName.text = city.cnName;
    cell.enName.text = city.enName;
    cell.pm.text =[NSString stringWithFormat:@"%d", city.pm25];
    
    if (self.isSettingMode) {
        cell.pm.hidden = YES;
        cell.uiSwitch.hidden = NO;
        BOOL selected = [self isSelectedCity:city];
         cell.uiSwitch.on = selected;
        // [checkSwitch setOn:selected animated:YES];
    }else{
        cell.pm.hidden = NO;
        cell.uiSwitch.hidden = YES;
    }
    
    BOOL selected = [self isSelectedCity:city];
    if (selected) {
//        cell.backgroundColor = Rgb2UIColor(<#r#>, <#g#>, <#b#>);
        cell.backgroundColor = [UIColor whiteColor];
        cell.cnName.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.enName.font = [UIFont boldSystemFontOfSize:13.0f];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.cnName.font = [UIFont systemFontOfSize:16.0f];
        cell.enName.font = [UIFont systemFontOfSize:13.0f];
    }
    
    cell.uiSwitch.tag = indexPath.row;
    [cell.uiSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    int pm25 = city.pm25;
    if (pm25>=200) {
        cell.pm.textColor = [UIColor purpleColor];
    }
    else if (pm25>=150) {
        cell.pm.textColor = [UIColor redColor];
    }
    else if (pm25>=100) {
        cell.pm.textColor = [UIColor blueColor];
    } else {
        cell.pm.textColor = [UIColor greenColor];
    }
    
    return cell;
}

- (void) changeSwitch:(UISwitch *) sender{
    NSInteger  index = sender.tag;
    City *city = [self.currentCityList objectAtIndex:index];
    
    [self updateFilterList:city selected:sender.on];
}

- (void) updateFilterList:(City *) city  selected:(BOOL) selected {
    if ([self isSelectedCity:city]) {
        if (selected) {
            
        } else {
            [self.selectedCityList removeObject:city.cnName];
        }
        
    } else {
        if (selected) {
            [self.selectedCityList addObject:city.cnName];
        } else {
            
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.currentCityList count];
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
