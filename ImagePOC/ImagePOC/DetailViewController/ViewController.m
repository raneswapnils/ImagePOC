//
//  ViewController.m
//  ImagePOC
//
//  Created by Swapnil Rane on 18/07/16.
//  Copyright © 2016 swapnil. All rights reserved.
//

#import "ViewController.h"
#import "RequestResponseParser.h"
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"
#import "DetailsInfo.h"
#import "UIImageView+WebCache.h"

#define CELL_CONTENT_MARGIN 20.0f

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *detailsTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UINavigationItem *navigationItem;
@property (nonatomic, strong) UIRefreshControl *tabelViewRefreshControl;

@end

@implementation ViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeTableView];
    
    [self initializeNavigationBar];
    
    self.tabelViewRefreshControl = [[UIRefreshControl alloc] init];
    
    [self.tabelViewRefreshControl addTarget:self action:@selector(pullToRefreshData:) forControlEvents:UIControlEventValueChanged];
    
    [self.detailsTableView addSubview:self.tabelViewRefreshControl];
    
    [self loadDataFromWebService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Private Methods

/*! This method will initialize tableview */

-(void)initializeTableView {
    
    self.detailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44) style:UITableViewStylePlain];
    self.detailsTableView.dataSource = self;
    self.detailsTableView.delegate = self;
    self.detailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.detailsTableView.separatorInset = UIEdgeInsetsZero;
    self.detailsTableView.layoutMargins = UIEdgeInsetsZero;
    [self.view addSubview:self.detailsTableView];
}

-(void)initializeNavigationBar {
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [self.view addSubview:navigationBar];
    self.navigationItem = [[UINavigationItem alloc]init];
    navigationBar.items = @[self.navigationItem];
}

-(void)loadDataFromWebService {
    
    RequestResponseParser *requestResponseParser = [[RequestResponseParser alloc]init];
    
    [requestResponseParser callApiRequest:^(BOOL status, NSError *error) {
        
        if(status) {
            [self fetchResult];
            NSString *title = [[NSUserDefaults standardUserDefaults]stringForKey:@"title"];
            self.navigationItem.title = title;
        }
    }];
}

/*! This method will fetch cached data */

-(void)fetchResult {
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DetailsInfo"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[CoreDataManager sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

#pragma mark- pull to refresh functionality

- (void) pullToRefreshData:(id) sender {
    
    [[CoreDataManager sharedInstance]deleteDataForEntity:@"DetailsInfo"];
    [self loadDataFromWebService];
    [self.tabelViewRefreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sections = [self.fetchedResultsController sections];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myCellIdentifier = @"MyCellIdentifier";
    
    UITableViewCell *cell = [self.detailsTableView dequeueReusableCellWithIdentifier:myCellIdentifier];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myCellIdentifier];
    }
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DetailsInfo *detailsInfoObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12];
    cell.detailTextLabel.font=[UIFont fontWithName:@"Arial" size:10];
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.text = detailsInfoObject.title;
    cell.detailTextLabel.text = detailsInfoObject.detailDescription;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:detailsInfoObject.imageRef]
                      placeholderImage:[UIImage imageNamed:@"noImage"]];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsInfo *detailsInfoObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *detailText = detailsInfoObject.detailDescription;
    
    if([detailText length]) {
        
        CGSize constraint = CGSizeMake(self.view.bounds.size.width - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:detailText
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}];
        CGRect rect = [attributedText boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize size = rect.size;
        
        CGFloat height = MAX(size.height, 40.0f);
        
        return height + (CELL_CONTENT_MARGIN * 2);
    }
    else {
        
        return 40.0f;
    }
}

@end