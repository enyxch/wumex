//
//  WUProjectViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUProjectViewController.h"
#import "WYStoryboardPopoverSegue.h"
#import "WUSettingsPopViewController.h"

#import "WUProjectHTTPRequestProvider.h"
#import "WULabelHTTPRequestProvider.h"
#import "WUTaskHTTPRequestProvider.h"

#import "WUTaskViewController.h"

#import "SKInnerShadowLayer.h"

#import "TaskViewCell.h"
#import "TaskDateViewCell.h"
#import "LabelViewCell.h"
#import "NewLabelViewCell.h"

static NSString *kSubitems = @"Subitems";
static NSString *kTask = @"Task";
static NSString *kLabel = @"Label";
static NSString *kDate = @"Date";
static NSString *kNewLabel = @"NewLabel";
static NSString *kNewTask = @"NewTask";
static NSString *kLabelId = @"LabelId";

@interface WUProjectViewController () <WYPopoverControllerDelegate, WUSettingsDelegate, UITableViewDelegate, TreeTableDataSource, NewLabelViewCellDelegate, LabelViewCellDelegate>
{
    WYPopoverController *settingPopoverController;
}
@property (strong, nonatomic) NSMutableDictionary *expandedItems;
@property (strong, nonatomic) NSMutableArray *listOfLabels;
@property (strong, nonatomic) NSArray *listOfTask;
@property (strong, nonatomic) NSMutableArray *listData;

@end

@implementation WUProjectViewController

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
    
    self.textFieldTitle.borderStyle = UITextBorderStyleNone;
    self.pickerDeadline.borderStyle = UITextBorderStyleNone;
    self.textFieldTimeSpend.borderStyle = UITextBorderStyleNone;
    
    self.textViewDescription.placeholder = NSLocalizedString(@"Description", @"placeholder");
    [self.textViewDescription setKeyboardDismissMode:UIScrollViewKeyboardDismissModeNone];
    
    [self.pickerDeadline setDropDownMode:IQDropDownModeDatePicker];
    [self.textFieldTitle setPlaceholder: NSLocalizedString(@"Title", @"placeholder")];
    [self.pickerDeadline setPlaceholder: NSLocalizedString(@"Date", @"placeholder")];
    [self.textFieldTimeSpend setPlaceholder: NSLocalizedString(@"Time in hours", @"placeholder")];
    [self.buttonEditTable setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    
    [self setIsEditMode:self.isEditMode animated:NO];
    
    if (self.project) {
        [self setupViewForProject:self.project animated:NO];
        [self loadTaskAndLabel];
    }
    
	_expandedItems = @{}.mutableCopy;
	    
    [self.tableViewLabels setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTaskAndLabel
{
    WUProjectViewController * __weak weakSelf = self;
        
    [[WUTaskHTTPRequestProvider sharedInstance] getTasksWithProjectId:weakSelf.project.projectId success:^(NSDictionary *response) {
        
        weakSelf.listOfTask = [NSMutableArray arrayWithArray:response[@"tasks"]];
        
        [[WULabelHTTPRequestProvider sharedInstance] getLabelsWithProjectId:weakSelf.project.projectId success:^(NSDictionary *response) {
            
            weakSelf.listOfLabels = [NSMutableArray arrayWithArray:response[@"labels"]];
            
            [weakSelf fillLabelsWithTasks];
            [weakSelf createListData];
            [weakSelf.tableViewLabels reloadData];
            
            [weakSelf updateTableView];
                         
        } failure:^(NSString *errorCode) {
            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
            [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
        }];
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)fillLabelsWithTasks
{
    for (WULabel* label in self.listOfLabels) {
        for (WUTask* task in self.listOfTask) {
            if ([task.labelId intValue] == [label.labelId intValue]) {
                [label addTask:task];
            }
        }
    }
    [self sortListOfLabelByPosition:self.listOfLabels];
}

- (void)sortListOfLabelByPosition:(NSMutableArray*)list
{
    [list sortUsingFunction:comparePositionLabel context:nil];
}

NSComparisonResult comparePositionLabel(WULabel* t1, WULabel* t2, void* context)
{
    return [t1.position compare:t2.position];
}

- (void)createListData
{
    NSMutableArray* array = [NSMutableArray array];
    for (WULabel* label in self.listOfLabels) {
        [array addObject:[self labelToDictionary:label]];
    }
    [array addObject:[NSMutableDictionary dictionaryWithDictionary:@{kNewLabel: @(YES)}]];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{kSubitems: array}];
    self.listData = [NSMutableArray arrayWithObject:dictionary];
}

- (NSMutableDictionary*)labelToDictionary:(WULabel*)label
{
    NSMutableArray* subItems = [NSMutableArray array];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate *lastDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDateComponents *lastCmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:lastDate];
    
    for (id<IQCalendarDataSource> data in label.listOfTask) {
        NSDate *startDate = [data startDate];
        NSDateComponents *cmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:startDate];
        if (![cmpnts isEqual:lastCmpnts]) {
            lastDate = [calendar dateFromComponents:cmpnts];
            lastCmpnts = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:lastDate];
            [subItems addObject:@{kDate: lastDate}];
        }
        if ([data isKindOfClass:[WULabel class]]) {
            [subItems addObject:[self labelToDictionary:data]];
        } else if ([data isKindOfClass:[WUTask class]]) {
            [subItems addObject:@{kTask: data}];
        }
    }
    [subItems addObject:[NSMutableDictionary dictionaryWithDictionary:@{kNewTask: @(YES),
                                                                        kLabelId: (label.labelId)?label.labelId: [NSNull null]}]];
    return [NSMutableDictionary dictionaryWithDictionary:@{kSubitems: subItems,
             kLabel: label}];
}

- (void)cancel
{
    if (self.project == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self setIsEditMode:NO animated:YES];
        [self setupViewForProject:self.project animated:YES];
    }
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"WUSettingsPopViewSegue" sender:self.navigationItem.rightBarButtonItem];
}

- (void)save
{
    if ([self isFormValid]) {
        WUProject *projectEdited = [[WUProject alloc] init];
        projectEdited.title = self.textFieldTitle.text;
        projectEdited.deadline = [self.pickerDeadline selectedDate];
        projectEdited.details = self.textViewDescription.text;
        
        WUProjectViewController * __weak weakSelf = self;
        
        //Store in the DB
        if (self.project == nil) {
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Creating project", nil)];
            [[WUProjectHTTPRequestProvider sharedInstance] createProject:projectEdited success:^(NSDictionary *response) {
                
                weakSelf.project = projectEdited;
                [weakSelf setIsEditMode:NO animated:YES];
                [weakSelf setupViewForProject:projectEdited animated:YES];
                
                [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Project created", nil) forDelay:1];
                
                
            } failure:^(NSString *errorCode) {
                [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
                [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
            }];
        } else {
            
            projectEdited.projectId = self.project.projectId;
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Updating project", nil)];
            [[WUProjectHTTPRequestProvider sharedInstance] updateProject:projectEdited success:^(NSDictionary *response) {
                
                weakSelf.project = projectEdited;
                [weakSelf setIsEditMode:NO animated:YES];
                [weakSelf setupViewForProject:projectEdited animated:YES];
                
                [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Project updated", nil) forDelay:1];
                
            } failure:^(NSString *errorCode) {
                [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
                [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
            }];
        }
    }
}

- (void)setupViewForProject:(WUProject*)project animated:(BOOL)animated
{
    self.textFieldTitle.text = project.title;
    
    if (project.deadline == nil) {
        [self.pickerDeadline setHidden:YES];
        [self.labelDeadline setHidden:YES];
        self.constraintDistanceBetweenDeadlineTimeSpend.constant = -31;
    } else {
        [self.pickerDeadline setDate:project.deadline animated:NO];
    }
    if (project.details == nil || [project.details isEqualToString:@""]) {
        [self.textViewDescription setHidden:YES];
    } else {
        self.textViewDescription.text = project.details;
        [self updateHeightTextView:self.textViewDescription withLimit:5000];
    }
    CGFloat duration = animated ? 0.7f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)isFormValid
{
    BOOL result = YES;
    NSString *title, *message;
    if ([self.textFieldTitle.text isEqualToString:@""]) {
        result = NO;
        title = NSLocalizedString(@"Title", @"title");
        message = NSLocalizedString(@"We need a title to create a project", @"message");
    }
    
    if (!result) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:NSLocalizedString(@"Ok", nil)
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        [alertView show];
    }
    return result;
}

- (void)delete
{
    if (self.project == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        WUProjectViewController * __weak weakSelf = self;
        [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Deleting project", nil)];
        [[WUProjectHTTPRequestProvider sharedInstance] deleteWithProjectId:self.project.projectId success:^(NSDictionary *response) {
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Project deleted", nil) forDelay:1];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSString *errorCode) {
            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
            [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
        }];
    }
}

#pragma mark - Set

- (void)setIsEditMode:(BOOL)isEditMode
{
    [self setIsEditMode:isEditMode animated:NO];
}

- (void)setIsEditMode:(BOOL)isEditMode animated:(BOOL)animated
{
    [self.pickerDeadline setHidden:NO];
    [self.labelDeadline setHidden:NO];
    [self.textViewDescription setHidden:NO];
    self.constraintDistanceBetweenDeadlineTimeSpend.constant = -1;
    
    _isEditMode = isEditMode;
    self.textFieldTitle.enabled = isEditMode;
    self.pickerDeadline.enabled = isEditMode;
    self.textFieldTimeSpend.enabled = isEditMode;
    [self.textViewDescription setEditable:isEditMode];
    [self.textViewDescription setSelectable:isEditMode];
    
    CGFloat textFieldHeight;
    if (isEditMode) {
        textFieldHeight = 44;
        self.textFieldTitle.clearButtonMode = UITextFieldViewModeAlways;
        self.pickerDeadline.clearButtonMode = UITextFieldViewModeAlways;
        self.textFieldTimeSpend.clearButtonMode = UITextFieldViewModeAlways;
        
        CGFloat duration = animated ? 0.7f : 0.0f;
        [UIView animateWithDuration:duration animations:^{
            self.textFieldTitle.borderStyle = UITextBorderStyleLine;
            self.pickerDeadline.borderStyle = UITextBorderStyleLine;
            self.textFieldTimeSpend.borderStyle = UITextBorderStyleLine;
            self.textViewDescription.layer.borderColor = [UIColor blackColor].CGColor;
            self.textViewDescription.layer.borderWidth = 1.0f;
        }];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
    } else {
        textFieldHeight = 30;
        self.textFieldTitle.clearButtonMode = UITextFieldViewModeNever;
        self.pickerDeadline.clearButtonMode = UITextFieldViewModeNever;
        self.textFieldTimeSpend.clearButtonMode = UITextFieldViewModeNever;
        
        self.textFieldTitle.borderStyle = UITextBorderStyleNone;
        self.pickerDeadline.borderStyle = UITextBorderStyleNone;
        self.textFieldTimeSpend.borderStyle = UITextBorderStyleNone;
        self.textViewDescription.layer.borderWidth = 0.0f;
        
        self.navigationItem.leftBarButtonItem =  nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    }
    
    for (NSLayoutConstraint *constraint in self.listConstraintTextFieldHeight) {
        constraint.constant = textFieldHeight;
    }
    
    CGFloat duration = animated ? 0.7f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)setEditTableView:(id)sender
{
    for (NSIndexPath* indexPath in self.expandedItems.allKeys) {
        [self.expandedItems removeObjectForKey:indexPath];
        [self.tableViewLabels collapse:indexPath];
    }
    [self.tableViewLabels reloadData];
    [self updateTableView];
    if ([self.tableViewLabels isEditing]) {
        [self.tableViewLabels setEditing:NO animated:YES];
        [self.buttonEditTable setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    } else {
        [self.tableViewLabels setEditing:YES animated:YES];
        [self.buttonEditTable setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WUSettingsPopViewSegue"])
    {
        WUSettingsPopViewController *settingVC = segue.destinationViewController;
        settingVC.delegate = self;
        settingVC.listAction = @[NSLocalizedString(@"Invite people", @"settings popView"),
                                 NSLocalizedString(@"Manage people", @"settings popView"),
                                 NSLocalizedString(@"Edit", @"settings popView"),
                                 NSLocalizedString(@"Delete", @"settings popView")];
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        settingPopoverController = [popoverSegue popoverControllerWithSender:sender
                                                    permittedArrowDirections:WYPopoverArrowDirectionDown
                                                                    animated:YES
                                                                     options:WYPopoverAnimationOptionFadeWithScale];
        settingPopoverController.theme = [WYPopoverTheme themeForColor:[UIHelper colorFromHex:PROJECT_COLOR]];
        settingPopoverController.delegate = self;
    }
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == settingPopoverController)
    {
        settingPopoverController.delegate = nil;
        settingPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

#pragma mark - WUSettingsDelegate

- (void)settingsView:(UIViewController*)viewController didSelectAction:(NSInteger)action
{
    [settingPopoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
        if (action == 2) {
            [self setIsEditMode:YES animated:YES];
        }
        if (action == 3) {
            [self delete];
        }
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateHeightTextView:textView withLimit:158];
    [textView resignFirstResponder];
    [textView becomeFirstResponder];
}

- (void)updateHeightTextView:(UITextView*)textView withLimit:(NSUInteger)limit
{
    NSInteger height = ceilf([textView sizeThatFits:textView.frame.size].height);
    NSInteger usefulHeight = MAX( MIN(height, limit), 44);
    self.constraintHeightTextViewDescription.constant = usefulHeight;
    [self.view layoutIfNeeded];
}

#pragma mark TreeTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.listData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSMutableDictionary *item = self.listData[section];
	return [item[kSubitems] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath {
	return nil != self.expandedItems[indexPath];
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *item = [self itemForIndexPath:indexPath];
	return [item[kSubitems] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
	NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
    if (item[kLabel] || item[kNewLabel]) {
        return 44.f;
    }
    if (item[kTask] || item[kNewTask]) {
        return 65.f;
    }
    if (item[kDate]) {
        return 22.f;
    }
	return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *item = [self itemForIndexPath:indexPath];
    
    NSIndexPath* parentIndex = [indexPath indexPathByRemovingLastIndex];
    
    NSMutableDictionary *parentItem = [self itemForIndexPath:parentIndex];
	
    if (item[kLabel]) {
        
        WULabel *label = item[kLabel];
        
        LabelViewCell *cell = [self.tableViewLabels dequeueReusableCellWithIdentifier:@"LabelViewCell"];
        
        if (cell == nil) {
            cell = [LabelViewCell sharedCell];
        }
        
        [cell setupWithLabel:label];
        cell.delegate = self;
        
        return cell;
        
    } else if (item[kTask]) {
        TaskViewCell *cell = [self.tableViewLabels dequeueReusableCellWithIdentifier:@"TaskViewCell"];
        if (cell == nil) {
            cell = [TaskViewCell sharedCell];
        }
        WUTask *task = item[kTask];
        
        cell.containingTableView = tableView;
        [cell setupWithTask:task];
                
        [cell showBottomShadow:([indexPath indexAtPosition:indexPath.length-1] == ((NSArray*)parentItem[kSubitems]).count - 1)];
        
        return cell;
        
    } else if (item[kDate]) {
        
        TaskDateViewCell *cell = [TaskDateViewCell sharedCell];
        
        if (cell == nil) {
            cell = [TaskDateViewCell sharedCell];
        }
        
        [cell setText:[[UIHelper localizedDateFormatterWithDateStyle:NSDateFormatterMediumStyle andTimeSyle:NSDateFormatterNoStyle] stringFromDate:item[kDate]]];
        
        [cell showTopShadow:([indexPath indexAtPosition:indexPath.length-1] == 0)];
        
        
        return cell;
        
    } else if (item[kNewLabel]) {
        
        NewLabelViewCell *cell = [self.tableViewLabels dequeueReusableCellWithIdentifier:@"NewLabelViewCell"];
        
        if (cell == nil) {
            cell = [NewLabelViewCell sharedCell];
        }
        
        [cell setText:NSLocalizedString(@"New task's list", nil)];
        cell.delegate = self;
        
        return cell;
        
    } else if (item[kNewTask]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewTask];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNewTask];
            
            cell.backgroundColor = [UIHelper colorFromHex:TASK_COLOR];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.textColor = [UIColor whiteColor];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            view.backgroundColor = [UIColor whiteColor];
            [cell addSubview:view];
            
            UIView *backgroundSelected = [[UIView alloc] initWithFrame:cell.bounds];
            backgroundSelected.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            UIView *dupSeparatorView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            dupSeparatorView2.backgroundColor = [UIColor whiteColor];
            [backgroundSelected addSubview:dupSeparatorView2];
            cell.selectedBackgroundView = backgroundSelected;
            
            SKInnerShadowLayer* innerShadowlayer = [[SKInnerShadowLayer alloc] init];
            innerShadowlayer.frame = CGRectMake(-10, -20, 340, 87);
            innerShadowlayer.innerShadowOpacity = 1.0f;
            innerShadowlayer.innerShadowOffset = CGSizeMake(0, -2);
            innerShadowlayer.innerShadowColor = [UIColor blackColor].CGColor;
            [cell.layer addSublayer:innerShadowlayer];
            
            if ([indexPath indexAtPosition:indexPath.length-1] == 0) {
                
                SKInnerShadowLayer* innerShadowlayer2 = [[SKInnerShadowLayer alloc] init];
                innerShadowlayer2.frame = CGRectMake(-10, 0, 340, 70);
                innerShadowlayer2.innerShadowOpacity = 1.0f;
                innerShadowlayer2.innerShadowOffset = CGSizeMake(0, 2);
                innerShadowlayer2.innerShadowColor = [UIColor blackColor].CGColor;
                [cell.layer addSublayer:innerShadowlayer2];
            }
            
            cell.layer.masksToBounds = YES;
        }
        
        cell.textLabel.text = NSLocalizedString(@"New task", nil);
        
        cell.imageView.image = [[UIImage imageNamed:@"chat_recipient_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor whiteColor];
        
        return cell;
    }
    
	return nil;
}

- (NSMutableDictionary *)itemForIndexPath:(NSIndexPath *)indexPath {
	NSArray *items = self.listData;
	NSMutableDictionary *item = self.listData[[indexPath indexAtPosition:0]];
	
	for (int i = 0; i < indexPath.length; i++) {
		NSUInteger idx = [indexPath indexAtPosition:i];
		
		item = items[idx];
		
		if (i == indexPath.length - 1) {
			return item;
		}
		
		items = item[kSubitems];
	}
	
	return item;
}

- (void)moveItemForIndexPath:(NSIndexPath *)indexPath toDestination:(NSIndexPath*)destinationIndexPath
{
    NSMutableDictionary *item = [self itemForIndexPath:indexPath];
    NSMutableDictionary *parentDictionary = [self itemForIndexPath:[indexPath indexPathByRemovingLastIndex]];
    NSMutableDictionary *parentDestinationDictionary = [self itemForIndexPath:[destinationIndexPath indexPathByRemovingLastIndex]];
    
    NSMutableArray *parentSubItem = parentDictionary[kSubitems];
    NSMutableArray *parentDestinationSubItem = parentDestinationDictionary[kSubitems];
    
    [parentSubItem removeObject:item];
    [parentDestinationSubItem insertObject:item atIndex:[destinationIndexPath indexAtPosition:destinationIndexPath.length-1]];
    [self updatePositionOfSubItems:parentDestinationSubItem];
    id tmp = self.expandedItems[indexPath];
    if (!self.expandedItems[destinationIndexPath]) {
        [self.expandedItems removeObjectForKey:indexPath];
    }
    if (tmp) {
        self.expandedItems[destinationIndexPath] = @(YES);
    }
}

- (void)updatePositionOfSubItems:(NSArray*)array
{
    int i = 1;
    for (NSMutableDictionary *item in array) {
        if (item[kLabel]) {
            ((WULabel*)item[kLabel]).position = [NSNumber numberWithInt:i];
            [[WULabelHTTPRequestProvider sharedInstance] updateLabel:((WULabel*)item[kLabel]) success:nil failure:nil];
        }
        i++;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![tableView isEditing]) {
        NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
        
        NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
        
        if (item[kNewTask]) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            WUTaskViewController* taskVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WUTaskViewController"];
            WUTask* task = [[WUTask alloc] init];
            
            task.projectId = self.project.projectId;
            task.labelId = item[kLabelId];
            
            taskVC.task = task;
            taskVC.isEditMode = YES;
            
            [self.tabBarController setSelectedIndex:2];
            UINavigationController* navTaskVC = [self.tabBarController.viewControllers objectAtIndex:2];
            if (![navTaskVC.topViewController isViewLoaded]) {
                [navTaskVC.topViewController loadView];
                [navTaskVC.topViewController viewDidLoad];
                [navTaskVC.topViewController viewWillAppear:YES];
            }
            [navTaskVC.topViewController.navigationController pushViewController:taskVC animated:YES];
            
            return;
        }
        
        if (item[kTask]) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            WUTaskViewController* taskVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WUTaskViewController"];
            WUTask* task = item[kTask];
            
            taskVC.task = task;
//            taskVC.isEditMode = YES;
            
            UINavigationController* navTaskVC = [self.tabBarController.viewControllers objectAtIndex:2];
            
            [navTaskVC popToRootViewControllerAnimated:NO];
            
            if (![navTaskVC.topViewController isViewLoaded]) {                
                [navTaskVC.topViewController loadView];
                [navTaskVC.topViewController viewDidLoad];
                [navTaskVC.topViewController viewWillAppear:YES];
            }
            [navTaskVC pushViewController:taskVC animated:YES];
            [self.tabBarController setSelectedIndex:2];
            
            return;
        }
        
        if (item[kLabel]) {
            BOOL isExpanded = [tableView isExpanded:treeIndexPath];
            if (isExpanded) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self.expandedItems removeObjectForKey:treeIndexPath];
                [tableView collapse:treeIndexPath];
            } else {
                
                // Unselect the cell "NewLabel"
                if ([tableView.indexPathsForSelectedRows containsObject:[NSIndexPath indexPathForItem:[tableView numberOfRowsInSection:0]-1 inSection:0]]) {
                    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:[tableView numberOfRowsInSection:0]-1 inSection:0] animated:YES];
                }
                
                self.expandedItems[treeIndexPath] = @(YES);
                [tableView expand:treeIndexPath];
            }
            
            [self updateTableView];
        }
        
        if (item[kNewLabel]) {
            return;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
    NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
    if (item[kSubitems]) {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
    NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
    if (item[kSubitems]) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
    NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
    if (item[kSubitems]) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *sourceTreeIndexPath = [tableView treeIndexPathFromTablePath:sourceIndexPath];
    NSIndexPath *proposedDestinationTreeIndexPath = [tableView treeIndexPathFromTablePath:proposedDestinationIndexPath];
    
    if (sourceTreeIndexPath.length > proposedDestinationTreeIndexPath.length) {
        return [tableView tableIndexPathFromTreePath:sourceTreeIndexPath];
    }
    
    while (proposedDestinationTreeIndexPath.length != sourceTreeIndexPath.length) {
        proposedDestinationTreeIndexPath = [proposedDestinationTreeIndexPath indexPathByRemovingLastIndex];
    }
    
    NSMutableDictionary *item = [self itemForIndexPath:[proposedDestinationTreeIndexPath indexPathByRemovingLastIndex]];
    if (((NSArray*)item[kSubitems]).count - 1 == [proposedDestinationTreeIndexPath indexAtPosition:proposedDestinationTreeIndexPath.length-1]) {
        return [[proposedDestinationTreeIndexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:((NSArray*)item[kSubitems]).count - 2];
    }
    
    return [tableView tableIndexPathFromTreePath:proposedDestinationTreeIndexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSIndexPath *sourceTreeIndexPath = [tableView treeIndexPathFromTablePath:sourceIndexPath];
    NSIndexPath *destinationTreeIndexPath = [tableView treeIndexPathFromTablePath:destinationIndexPath];
    
    [self moveItemForIndexPath:sourceTreeIndexPath toDestination:destinationTreeIndexPath];
    [tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:indexPath];
        NSMutableDictionary *item = [self itemForIndexPath:treeIndexPath];
        NSMutableDictionary *parentDictionary = [self itemForIndexPath:[treeIndexPath indexPathByRemovingLastIndex]];
        NSMutableArray *parentSubItem = parentDictionary[kSubitems];
        
        
        if (item[kLabel]) {
            WULabel* label = item[kLabel];
            
            WUProjectViewController * __weak weakSelf = self;
            [[WULabelHTTPRequestProvider sharedInstance] deleteWithLabelId:label.labelId success:^(NSDictionary *response) {
                [parentSubItem removeObjectAtIndex:[treeIndexPath indexAtPosition:treeIndexPath.length-1]];
                [weakSelf updatePositionOfSubItems:parentSubItem];
                
                if (weakSelf.expandedItems[treeIndexPath]) {
                    [weakSelf.expandedItems removeObjectForKey:treeIndexPath];
                }
                [weakSelf.tableViewLabels deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
            } failure:nil];
        }
    }
}

#pragma mark - TableView

- (void)updateTableView
{
    CGFloat height = 0.0f;
    for (int i = 0 ; i < [self.tableViewLabels numberOfRowsInSection:0]; i++) {
        height += [self tableView:self.tableViewLabels heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.constraintHeightTableViewLabels.constant = height;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - NewLabelViewCellDelegate

- (void)newLabelViewCell:(NewLabelViewCell *)cell didCreateNewLabel:(WULabel *)label
{
    NSIndexPath* indexPath = [self.tableViewLabels treeIndexPathForItem:cell];
    NSMutableDictionary *parentDictionary = [self itemForIndexPath:[indexPath indexPathByRemovingLastIndex]];
    NSMutableArray *parentSubItem = parentDictionary[kSubitems];
    
    label.position = [NSNumber numberWithInteger:parentSubItem.count];
    label.projectId = self.project.projectId;
    
    WUProjectViewController * __weak weakSelf = self;
    
    [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Creating list", nil)];
    
    [[WULabelHTTPRequestProvider sharedInstance] createLabel:label success:^(NSDictionary *response) {
        
        [parentSubItem insertObject:[weakSelf labelToDictionary:label] atIndex:parentSubItem.count-1];
        [weakSelf.tableViewLabels reloadData];
        [weakSelf updateTableView];
        
        [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"List created", nil) forDelay:1];
        
    } failure:nil];
    
}

#pragma mark - LabelViewCellDelegate

- (void)labelViewCell:(NewLabelViewCell *)cell didUpdateLabel:(WULabel *)label
{
    NSIndexPath* indexPath = [self.tableViewLabels treeIndexPathForItem:cell];
    NSMutableDictionary *parentDictionary = [self itemForIndexPath:[indexPath indexPathByRemovingLastIndex]];
    NSMutableArray *parentSubItem = parentDictionary[kSubitems];
    
    WUProjectViewController * __weak weakSelf = self;
    
    [[WULabelHTTPRequestProvider sharedInstance] updateLabel:label success:^(NSDictionary *response) {
        
        [parentSubItem replaceObjectAtIndex:[indexPath indexAtPosition:indexPath.length-1] withObject:[weakSelf labelToDictionary:label]];
        
    } failure:nil];
    
}

@end
