//
//  WUMainProjectsViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 20.05.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUMainProjectsViewController.h"

#import "ProjectViewCell.h"
#import "WUProjectViewController.h"
#import "WUProjectHTTPRequestProvider.h"

@interface WUMainProjectsViewController ()

@end

@implementation WUMainProjectsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.tabBarItem) {
        [self.tabBarItem setTitle:NSLocalizedString(@"Projects", nil)];
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_project"]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbar_project_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIHelper colorFromHex:PROJECT_COLOR]}
                                       forState:UIControlStateSelected];
    }
    
    self.filteredList = [NSMutableArray array];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    self.searchBar.tintColor = [UIHelper colorFromHex:PROJECT_COLOR];
    self.searchBar.placeholder = NSLocalizedString(@"Search project", nil);
    self.searchBar.delegate = self;
//    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//    self.mySearchDisplayController.delegate = self;
//    self.mySearchDisplayController.searchResultsDataSource = self;
//    self.mySearchDisplayController.searchResultsDelegate = self;
    
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"My projects", nil), NSLocalizedString(@"All projects", nil)]];
    [self.segmentControl setSelectedSegmentIndex:0];
    self.searchBarNewItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newProject:)];
    
    [self setupNavBar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup when the view is about to made visible.
    if (self.navigationController) {
        if (self.navigationController.navigationBar) {
            [self.navigationController.navigationBar setBarTintColor:[UIHelper colorFromHex:PROJECT_COLOR]];
        }
    }
    WUMainProjectsViewController * __weak weakSelf = self;
    
    [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Downloading data", nil)];
    [[WUProjectHTTPRequestProvider sharedInstance] getProjectsWithSuccess:^(NSDictionary *response) {
        
        weakSelf.listOfProject = [NSMutableArray arrayWithArray:response[@"projects"]];
        [weakSelf sortListOfProjectByDate:weakSelf.listOfProject];
        
        [weakSelf.tableView reloadData];
        
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredList removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.title CONTAINS[cd] %@) OR (SELF.details CONTAINS[cd] %@)", searchText, searchText];
    self.filteredList  = [NSMutableArray arrayWithArray:[self.listOfProject filteredArrayUsingPredicate:predicate]];
    [self sortListOfProjectByDate:self.filteredList];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText scope:[searchBar selectedScopeButtonIndex]];
    [self.tableView reloadData];
}

//#pragma mark - UISearchDisplayController Delegate Methods
//
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    // Tells the table data source to reload when text changes
//
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    
//    [self filterContentForSearchText:searchString scope:[controller.searchBar selectedScopeButtonIndex]];
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}
//
//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:controller.searchBar.text scope:searchOption];
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}

- (void)sortListOfProjectByDate:(NSMutableArray*)list
{
    [list sortUsingFunction:compareDateProject context:nil];
}

NSComparisonResult compareDateProject(WUProject* t1, WUProject* t2, void* context)
{
    return [t2.updatedDate compare:t1.updatedDate];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isSearching) {
        return self.listOfProject.count;
    } else {
        return self.filteredList.count;
    }
}

- (CGFloat)tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath
{
    return 66.0f;
}

- (UITableViewCell*)tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    ProjectViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProjectViewCell"];
    
    if (cell == nil) {
        cell = [ProjectViewCell sharedCell];
    }
    
    WUProject* project;
    if (!isSearching) {
        project = self.listOfProject[indexPath.row];
    } else {
        project = self.filteredList[indexPath.row];
    }
    
    [cell setTitle:project.title];
    [cell setDetails:project.details];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUProject* project;
    if (!isSearching) {
        project = self.listOfProject[indexPath.row];
    } else {
        project = self.filteredList[indexPath.row];
    }
    
    WUProjectViewController* projectVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WUProjectViewController"];
    projectVC.project = project;
    [self.navigationController pushViewController:projectVC animated:YES];
}

- (IBAction)newProject:(id)sender
{
    WUProjectViewController* projectVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WUProjectViewController"];
    [projectVC setIsEditMode:YES];
    [self.navigationController pushViewController:projectVC animated:YES];
}

@end
