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
#import <SafariServices/SafariServices.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AFHTTPRequestOperationManager *afManager;
@property (nonatomic, copy) NSArray *pages;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSString *currentQuery;

@end

typedef void(^CompletionBlock)(NSArray* results);

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.pages = [NSMutableArray array];
    
    [self configureSearchController];
    
    UINib *pageCellNib = [UINib nibWithNibName:@"PageCell" bundle:nil];
    [self.tableView registerNib:pageCellNib forCellReuseIdentifier:NSStringFromClass([PageCell class])];
    
    self.afManager = [AFHTTPRequestOperationManager manager];
    [self fetchPages:nil completionBlock:^(NSArray *pageObjects) {
        self.pages = pageObjects;
        [self.tableView reloadData];
    }];
}

- (void)configureSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search Stack Overflow browsing history ...";
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.searchBar.enablesReturnKeyAutomatically = NO;
    
    UITextField *textField = [self.searchController.searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.currentQuery = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Deselect previously selected row
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchPages:(NSString *)query completionBlock:(CompletionBlock)completionBlock{
    
    NSMutableDictionary *parameters = [@{@"login":@"psytronx"} mutableCopy];
    if (query){
        [parameters setObject:query forKey:@"q"];
    }
    
    [self.afManager GET:@"https://agile-plains-3571.herokuapp.com/sotracker/pages" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseJson) {
        NSLog(@"JSON: %@", responseJson);
        if ([responseJson isKindOfClass:[NSArray class]]) {
            // Parse JSON into SOTPage objects
            NSArray *pagesJson = responseJson;
            NSMutableArray *pageObjects = [NSMutableArray arrayWithCapacity:pagesJson.count];
            [pagesJson enumerateObjectsUsingBlock:^(NSDictionary* pageDict, NSUInteger i, BOOL* stop) {
                SOTPage *page = [[SOTPage alloc] initWithDictionary:pageDict];
                [pageObjects addObject:page];
            }];
            completionBlock(pageObjects);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pages){
        NSInteger row = [indexPath row];
        NSString *urlString = [NSString stringWithFormat:@"https://www.stackoverflow.com%@", ((SOTPage *)self.pages[row]).path];
        NSLog(@"Path: %@", urlString);
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
        [self presentViewController:safariVC animated:YES completion:nil];
    }
}

#pragma mark - UISearchResult

- (void) updateSearchResultsForSearchController: (UISearchController *)searchController {
    NSLog(@"In updateSearchResultsForSearchController:");
    //...
}

#pragma mark - UISearchBarDelegate methods

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarCancelButtonClicked: ");
    [self.searchController.searchBar resignFirstResponder];
    self.searchController.active = false;
    
    // Hacky way of preserving current search query string if Cancel is pressed. Todo - Find a better way!
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchController.searchBar.text = self.currentQuery;
    });
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked: ");
    NSString *query = searchBar.text;
    [self fetchPages:query completionBlock:^(NSArray *pageObjects) {
        self.pages = pageObjects;
        [self.searchController.searchBar resignFirstResponder];
        self.searchController.active = false;
        self.searchController.searchBar.text = query;
        self.currentQuery = query;
        [self.tableView reloadData];
    }];
    
}

@end
