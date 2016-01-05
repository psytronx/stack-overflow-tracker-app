//
//  ViewController.m
//  SO Tracker
//
//  Created by psytronx on 1/3/16.
//  Copyright © 2016 Logical Dimension. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AFHTTPRequestOperationManager *afManager;
@property (nonatomic, strong) NSArray *pages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Register cell class for tableView
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // Fetch pages
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
            self.pages = responseObject;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a cell from the pool
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    // Configure the cell
    if (self.pages){
        NSInteger index = [indexPath row];
        NSDictionary *result = self.pages[index];
        NSString *title = result[@"title"];
        [cell.textLabel setText:title];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Row pressed");
    
    //Convenience variables
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    // ... Do something with section and row ...
}

@end
