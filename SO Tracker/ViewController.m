//
//  ViewController.m
//  SO Tracker
//
//  Created by psytronx on 1/3/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import "ViewController.h"
#import "PageCell.h"
#import "SOTPage.h"
#import <AFNetworking.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AFHTTPRequestOperationManager *afManager;
@property (nonatomic, strong) NSMutableArray *pages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.pages = [NSMutableArray array];
    
    // Register Cell
    UINib *pageCellNib = [UINib nibWithNibName:@"PageCell" bundle:nil];
    [self.tableView registerNib:pageCellNib forCellReuseIdentifier:NSStringFromClass([PageCell class])];
    
    self.afManager = [AFHTTPRequestOperationManager manager];
    [self fetchPages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchPages {
    
    [self.afManager GET:@"https://agile-plains-3571.herokuapp.com/sotracker/pages" parameters:@{@"login":@"psytronx"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSArray class]]) {
            
            // Parse JSON into SOTPage objects
            NSArray *pages = responseObject;
            [pages enumerateObjectsUsingBlock:^(NSDictionary* pageDict, NSUInteger i, BOOL* stop) {
                SOTPage *page = [[SOTPage alloc] initWithDictionary:pageDict];
                [self.pages addObject:page];
            }];
            
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: responseObject should be an array. Houston, we have a problem.");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}


#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (!self.pages) {
        return 10; // Just show something while data is loading.
    }
    return self.pages.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pages){
        SOTPage *page = self.pages[indexPath.row];
        CGFloat height = [PageCell getCellHeightForPage:page width:self.view.bounds.size.width];
        return height;
    } else {
        return 100;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a cell from the pool
    PageCell *cell = (PageCell *)[tableView dequeueReusableCellWithIdentifier:@"PageCell" forIndexPath:indexPath];
    
    // Configure the cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (self.pages){
        cell.page = self.pages[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Row pressed");
    
    //Convenience variables
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    // ... Do something with section and row ...
}

@end
