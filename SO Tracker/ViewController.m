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
#import "CustomActivityIndicatorView.h"
#import <AFNetworking.h>
#import <SafariServices/SafariServices.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CustomActivityIndicatorView *customActivityIndicator;
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
    
    // Setup Activity Indicator
    // todo - Refactor this into a method
    // todo - Add subview to topmost view of key window, so that it's not grayed out by search controller.
    self.customActivityIndicator = [[CustomActivityIndicatorView alloc] init];
    self.customActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.customActivityIndicator];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.customActivityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.f
                                                                constant:0.f];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.customActivityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.f
                                                                constant:0.f];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.customActivityIndicator
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0.f constant:73];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.customActivityIndicator
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0.f constant:73];
    [self.view addConstraints:@[centerXConstraint, centerYConstraint, heightConstraint, widthConstraint]];
    
    self.customActivityIndicator.hidden = NO;
    self.afManager = [AFHTTPRequestOperationManager manager];
    [self fetchPages:nil completionBlock:^(NSArray *pageObjects) {
        self.pages = pageObjects;
        [self.tableView reloadData];
        self.customActivityIndicator.hidden = YES;
    }];
}

- (void)configureSearchController {
    
    // Set background color of nav bar
    UIColor *backgroundColor = [UIColor colorWithRed:51.0/255 green:76.0/255 blue:118.0/255 alpha:1];
    UIView* ctrl = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    ctrl.backgroundColor = backgroundColor;
    ctrl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.navigationController.navigationBar addSubview:ctrl];
    
    // Configure search controller and place search bar in nav bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search Stack Overflow browsing history ...";
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.searchBar.enablesReturnKeyAutomatically = NO;
    self.searchController.searchBar.backgroundColor = backgroundColor;
    self.navigationItem.titleView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];

    // Make sure Search button on keyboard remains enabled even if text is blank
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

// Todo - is a separate data source class needed?
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

static const CGFloat filterBarHeight = 30;

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    // Filter View
    CGRect filterFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, filterBarHeight);
    UIView *filterView = [[UIView alloc] initWithFrame:filterFrame];
    filterView.backgroundColor = [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1];
    
    CGRect labelFrame = CGRectMake(0, 0, self.tableView.bounds.size.width, filterBarHeight);
    UILabel *label = [[UILabel alloc] initWithFrame: labelFrame];
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderColor = [[UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1] CGColor];
    label.layer.borderWidth = 2;
    label.text = @"Place-holder for filter bar.";
    [filterView addSubview:label];
    
    return filterView;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    // Height for Filter View
    return filterBarHeight;
    
}

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
    self.customActivityIndicator.hidden = NO;
    [self fetchPages:query completionBlock:^(NSArray *pageObjects) {
        self.pages = pageObjects;
        [self.searchController.searchBar resignFirstResponder];
        self.searchController.active = false;
        self.searchController.searchBar.text = query;
        self.currentQuery = query;
        [self.tableView reloadData];
        self.customActivityIndicator.hidden = YES;
    }];
    
}

@end
