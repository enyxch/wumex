//
//  WUTaskViewController.m
//  Wumex
//
//  Created by Nicolas Bonnet on 18.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUTaskViewController.h"

#import "WYStoryboardPopoverSegue.h"
#import "WUSettingsPopViewController.h"

#import "WUProjectHTTPRequestProvider.h"
#import "WULabelHTTPRequestProvider.h"
#import "WUTaskHTTPRequestProvider.h"

@interface WUTaskViewController () <WUSettingsDelegate, WYPopoverControllerDelegate>
{
    WYPopoverController *settingPopoverController;
    BOOL popOnCancel;
}

@property (nonatomic, strong) NSArray *listOfProject;
@property (nonatomic, strong) NSArray *listOfLabel;
//@property (nonatomic, assign) NSInteger selectedProject;
//@property (nonatomic, assign) NSInteger selectedLabel;

@end

@implementation WUTaskViewController

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
    
    for (UITextField* textField in self.listOfTextField) {
        textField.borderStyle = UITextBorderStyleNone;
    }
    
    self.textViewDescription.placeholder = NSLocalizedString(@"Description", @"placeholder");
    [self.textViewDescription setKeyboardDismissMode:UIScrollViewKeyboardDismissModeNone];
    
    [self.pickerStartDate setDropDownMode:IQDropDownModeDatePicker];
    [self.pickerStartDate setPlaceholder:NSLocalizedString(@"Date", @"placeholder")];
    [self.pickerEndDate setDropDownMode:IQDropDownModeDatePicker];
    [self.pickerEndDate setPlaceholder:NSLocalizedString(@"Date", @"placeholder")];
    [self.pickerFromProject setDropDownMode:IQDropDownModeTextPicker];
    [self.pickerFromProject setPlaceholder:NSLocalizedString(@"Project", @"placeholder")];
    [self.pickerInList setDropDownMode:IQDropDownModeTextPicker];
    [self.pickerInList setPlaceholder:NSLocalizedString(@"List of task", @"placeholder")];
    
    [self.textFieldTitle setPlaceholder: NSLocalizedString(@"Title", @"placeholder")];
    
    [self.textFieldEstimatedTime setPlaceholder: NSLocalizedString(@"Time in hours", @"placeholder")];
    [self.textFieldTimeSpent setPlaceholder: NSLocalizedString(@"Time in hours", @"placeholder")];
    
    self.pickerFromProject.onValueChange = ^{
        self.task.projectId = ((WUProject*)[self.listOfProject objectAtIndex:[self.pickerFromProject selectedIndex]]).projectId;
        [self updateListOfLabelWithProjectId:self.task.projectId];
    };
    self.pickerInList.onValueChange = ^{
        if (self.listOfLabel.count == [self.pickerInList selectedIndex]) {
            self.pickerInList.text = @"";
            [self.pickerInList setDropDownMode:IQDropDownModeTextField];
            [self.pickerInList resignFirstResponder];
            [self.pickerInList becomeFirstResponder];
        } else {
            self.task.labelId = ((WULabel*)[self.listOfLabel objectAtIndex:[self.pickerInList selectedIndex]]).labelId;
        }
    };
    
    if (self.task) {
        [self setupViewForTask:self.task animated:NO];
        if (!self.task.title) {
            popOnCancel = YES;
        }
    } else {
        self.task = [[WUTask alloc] init];
        [self setupViewForTask:self.task animated:NO];
        popOnCancel = YES;
    }
    [self setEditMode:self.isEditMode animated:NO];
    [self.view layoutIfNeeded];
    
    [self downloadListOfProject];
}

- (void)downloadListOfProject
{
    [self.pickerFromProject.activityIndicator startAnimating];
    [self.pickerFromProject setEnabled:NO];
    [self.pickerInList.activityIndicator startAnimating];
    [self.pickerInList setEnabled:NO];
    WUTaskViewController * __weak weakSelf = self;
    
    [[WUProjectHTTPRequestProvider sharedInstance] getProjectsWithSuccess:^(NSDictionary *response) {
        
        weakSelf.listOfProject = [NSMutableArray arrayWithArray:response[@"projects"]];
        if (weakSelf.listOfProject.count == 0) {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"No project found", @"title") andMessage:NSLocalizedString(@"You have to create a project first !", @"message")];
            [alertView addButtonWithTitle:NSLocalizedString(@"Ok", nil)
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                      [weakSelf.navigationController popViewControllerAnimated:YES];
                                  }];
            [alertView show];
        } else {
            [weakSelf updatePickerProject];
        }
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)updateListOfLabelWithProjectId:(NSNumber*)projectId
{
    [self.pickerInList.activityIndicator startAnimating];
    [self.pickerInList setEnabled:NO];
    self.pickerInList.text = @"";
    WUTaskViewController * __weak weakSelf = self;
    
    [[WULabelHTTPRequestProvider sharedInstance] getLabelsWithProjectId:projectId success:^(NSDictionary *response) {
        
        weakSelf.listOfLabel = [NSMutableArray arrayWithArray:response[@"labels"]];
        [weakSelf updatePickerLabel];
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)updatePickerProject
{
    NSInteger selectedIndex = 0;
    NSMutableArray *arrayProjectTitle = [NSMutableArray array];
    
    for (WUProject* project in self.listOfProject) {
        if (self.task.projectId) {
            if ([project.projectId isEqualToNumber:self.task.projectId]) {
                selectedIndex = [self.listOfProject indexOfObject:project];
            }
        }
        [arrayProjectTitle addObject:project.title];
    }
    [self.pickerFromProject setItemList:[NSArray arrayWithArray:arrayProjectTitle]];
    [self.pickerFromProject selectAtIndex:selectedIndex];
    [self.pickerFromProject.activityIndicator stopAnimating];
    [self.pickerFromProject setEnabled:YES];
}

- (void)updatePickerLabel
{
    NSInteger selectedIndex = 0;
    NSMutableArray *arrayLabelTitle = [NSMutableArray array];
    
    for (WULabel* label in self.listOfLabel) {
        if (self.task.labelId) {
            if ([label.labelId isEqualToNumber:self.task.labelId]) {
                selectedIndex = [self.listOfLabel indexOfObject:label];
            }
        }
        [arrayLabelTitle addObject:label.title];
    }
    [arrayLabelTitle addObject:NSLocalizedString(@"New list of task", nil)];
    [self.pickerInList setItemList:[NSArray arrayWithArray:arrayLabelTitle]];
    if (arrayLabelTitle.count > 1) {
        [self.pickerInList setDropDownMode:IQDropDownModeTextPicker];
        [self.pickerInList selectAtIndex:selectedIndex];
    } else {
        [self.pickerInList setDropDownMode:IQDropDownModeTextField];
    }
    [self.pickerInList.activityIndicator stopAnimating];
    [self.pickerInList setEnabled:YES];
}

- (void)projectHasBeenSelected
{
    for (WUProject* project in self.listOfProject) {
        if ([project.title isEqualToString:self.pickerFromProject.selectedItem]) {
            self.task.projectId = project.projectId;
            break;
        }
    }
}

- (void)cancel
{
    if (popOnCancel) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self setEditMode:NO animated:YES];
        [self setupViewForTask:self.previousTask animated:YES];
        [UIView animateWithDuration:0.7f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"WUTaskSettingsPopViewSegue" sender:self.navigationItem.rightBarButtonItem];
}

- (void)save
{
    if ([self isFormValid]) {
        self.task.title = self.textFieldTitle.text;
        self.task.timeSpent = [NSNumber numberWithInt:[self.textFieldTimeSpent.text integerValue]*3*60*60];
        self.task.detail = self.textViewDescription.text;
        
        WUTaskViewController * __weak weakSelf = self;
        
        //Store in the DB
        if (self.previousTask.title == nil || [self.previousTask.title isEqualToString:@""]) {
            
            if (self.pickerInList.dropDownMode == IQDropDownModeTextField) {
                
                WULabel *label = [[WULabel alloc] init];
                label.title = self.pickerInList.text;
                label.position = [NSNumber numberWithInteger:self.listOfLabel.count];
                label.projectId = self.task.projectId;
                
                [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Creating task", nil)];
                [[WULabelHTTPRequestProvider sharedInstance] createLabel:label success:^(NSDictionary *response) {
                    
                    [weakSelf createTask:weakSelf.task];
                    
                } failure:nil];
            } else {
                [self createTask:self.task];
            }
            
        } else {
            
            [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Updating task", nil)];
            [[WUTaskHTTPRequestProvider sharedInstance] updateTask:self.task success:^(NSDictionary *response) {
                
                [weakSelf setEditMode:NO animated:YES];
                [weakSelf setupViewForTask:weakSelf.task animated:YES];
                
                [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Task updated", nil) forDelay:1];
                
            } failure:^(NSString *errorCode) {
                [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
                [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
            }];
        }
    }
}

- (void)createTask:(WUTask*)task
{
    WUTaskViewController * __weak weakSelf = self;
    
    [[WUTaskHTTPRequestProvider sharedInstance] createTask:self.task success:^(NSDictionary *response) {
        
        [weakSelf setEditMode:NO animated:YES];
        [weakSelf setupViewForTask:weakSelf.task animated:YES];
        
        [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Task created", nil) forDelay:1];
        
        
    } failure:^(NSString *errorCode) {
        [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
        [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
    }];
}

- (void)setupViewForTask:(WUTask*)task animated:(BOOL)animated
{
    self.previousTask = [task copy];
    popOnCancel = NO;
    self.textFieldTitle.text = task.title;
    
//    if (task.startDate == nil) {
//        [self hideViewWithConstraint:self.pickerStartDate];
//        [self.pickerStartDate setHidden:YES];
//        [self.labelStartDate setHidden:YES];
//    } else {
//    }
    [self.pickerStartDate setDate:task.startDate animated:NO];
    [self.pickerEndDate setDate:task.endDate animated:NO];
    [self.textFieldEstimatedTime setText:[UIHelper timeIntervalToString:self.task.estimatedTime]];
    [self.textFieldTimeSpent setText:[UIHelper timeIntervalToString:self.task.timeSpent]];
    
    if (task.detail == nil || [task.detail isEqualToString:@""]) {
        [self.textViewDescription setHidden:YES];
    } else {
        self.textViewDescription.text = task.detail;
        [self updateHeightTextView:self.textViewDescription withLimit:5000];
    }
}

- (void)hideViewWithConstraint:(UIView*)view
{
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = 0;
        }
    }
}

- (BOOL)isFormValid
{
    BOOL result = YES;
    NSString *title, *message;
    if ([self.textFieldTitle.text isEqualToString:@""]) {
        result = NO;
        title = NSLocalizedString(@"Title", @"title");
        message = NSLocalizedString(@"We need a title to create a task", @"message");
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
    if (self.task == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
//        WUTaskViewController * __weak weakSelf = self;
//        [[WUProgressIndicator defaultProgressIndicator] showSpinnerForView:weakSelf.view mode:MBProgressHUDModeIndeterminate message:NSLocalizedString(@"Deleting task", nil)];
//        [[WUProjectHTTPRequestProvider sharedInstance] deleteWithProjectId:self.project.projectId success:^(NSDictionary *response) {
//            
//            [[WUProgressIndicator defaultProgressIndicator] showSpinnerCompletedForView:weakSelf.view withText:NSLocalizedString(@"Task deleted", nil) forDelay:1];
//            [self.navigationController popViewControllerAnimated:YES];
//            
//        } failure:^(NSString *errorCode) {
//            [[WUProgressIndicator defaultProgressIndicator] hideSpinnerForView:weakSelf.view];
//            [[WUErrorHandler defaultHandler] displayAlertForErrorCode:errorCode];
//        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set

- (void)setEditMode:(BOOL)isEditMode
{
    [self setEditMode:isEditMode animated:NO];
}

- (void)setEditMode:(BOOL)isEditMode animated:(BOOL)animated
{
    [self.pickerEndDate setHidden:NO];
    [self.labelEndDate setHidden:NO];
    [self.pickerStartDate setHidden:NO];
    [self.labelStartDate setHidden:NO];
    [self.textViewDescription setHidden:NO];
    
    _isEditMode = isEditMode;
    
    for (UITextField* textField in self.listOfTextField) {
        textField.enabled = isEditMode;
    }
    
    [self.textViewDescription setEditable:isEditMode];
    [self.textViewDescription setSelectable:isEditMode];
    
    CGFloat textFieldHeight;
    if (isEditMode) {
        textFieldHeight = 44;
        
        for (UITextField* textField in self.listOfTextField) {
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }
        
        
        CGFloat duration = animated ? 0.7f : 0.0f;
        [UIView animateWithDuration:duration animations:^{
            
            for (UITextField* textField in self.listOfTextField) {
                textField.borderStyle = UITextBorderStyleLine;
            }
            
            self.textViewDescription.layer.borderColor = [UIColor blackColor].CGColor;
            self.textViewDescription.layer.borderWidth = 1.0f;
        }];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
    } else {
        textFieldHeight = 30;
        
        for (UITextField* textField in self.listOfTextField) {
            textField.clearButtonMode = UITextFieldViewModeNever;
        }
        
        for (UITextField* textField in self.listOfTextField) {
            textField.borderStyle = UITextBorderStyleNone;
        }
        self.textViewDescription.layer.borderWidth = 0.0f;
        
        self.navigationItem.leftBarButtonItem =  nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    }
    
    for (NSLayoutConstraint *constraint in self.listConstraintTextFieldHeight) {
        constraint.constant = textFieldHeight;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WUTaskSettingsPopViewSegue"])
    {
        WUSettingsPopViewController *settingVC = segue.destinationViewController;
        settingVC.delegate = self;
        settingVC.listAction = @[NSLocalizedString(@"Edit", @"settings popView"),
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
        if (action == 0) {
            [self setEditMode:YES animated:YES];
            
            [UIView animateWithDuration:0.7f animations:^{
                [self.view layoutIfNeeded];
            }];
        }
        if (action == 1) {
            [self delete];
        }
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateHeightTextView:textView withLimit:158];
    [self.view layoutIfNeeded];
    [textView resignFirstResponder];
    [textView becomeFirstResponder];
}

- (void)updateHeightTextView:(UITextView*)textView withLimit:(NSUInteger)limit
{
    NSInteger height = ceilf([textView sizeThatFits:textView.frame.size].height);
    NSInteger usefulHeight = MAX( MIN(height, limit), 44);
    self.constraintHeightTextViewDescription.constant = usefulHeight;
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.pickerStartDate]) {
        [self.pickerStartDate setDate:self.task.startDate animated:YES];
    } else if ([textField isEqual:self.pickerEndDate]) {
        [self.pickerEndDate setDate:self.task.endDate animated:YES];
    } else if ([textField isEqual:self.textFieldEstimatedTime]) {
        self.textFieldEstimatedTime.text = [NSString stringWithFormat:@"%d", [self.task.estimatedTime intValue]/(3*60*60)];
    } else if ([textField isEqual:self.textFieldTimeSpent]) {
        self.textFieldTimeSpent.text = [NSString stringWithFormat:@"%d", [self.task.timeSpent intValue]/(3*60*60)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.pickerStartDate]) {
        [self.task setStartDate:[self.pickerStartDate selectedDate]];
    } else if ([textField isEqual:self.pickerEndDate]) {
        [self.task setEndDate:[self.pickerEndDate selectedDate]];
    } else if ([textField isEqual:self.textFieldEstimatedTime]) {
        [self.task setEstimatedTime:[NSNumber numberWithInt:[self.textFieldEstimatedTime.text integerValue]*3*60*60]];
    } else if ([textField isEqual:self.textFieldTimeSpent]) {
        [self.task setTimeSpent:[NSNumber numberWithInt:[self.textFieldTimeSpent.text integerValue]*3*60*60]];
    }
    
    [self.pickerStartDate setDate:self.task.startDate animated:YES];
    [self.pickerEndDate setDate:self.task.endDate animated:YES];
    [self.textFieldEstimatedTime setText:[UIHelper timeIntervalToString:self.task.estimatedTime]];
    [self.textFieldTimeSpent setText:[UIHelper timeIntervalToString:self.task.timeSpent]];
}

@end
