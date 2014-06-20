//
//  WUProjectViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 02.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUViewController.h"

#import "IQDropDownTextField.h"
#import "WUProject.h"
#import "IQTextView.h"

#import "TreeTable.h"

@interface WUProjectViewController : WUViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDeadline;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *pickerDeadline;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeSpend;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTimeSpend;
@property (weak, nonatomic) IBOutlet IQTextView *textViewDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditTable;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLabels;
@property (strong, nonatomic) IBOutlet TreeTable *treeModel;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *listConstraintTextFieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceBetweenDeadlineTimeSpend;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTextViewDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTableViewLabels;

@property (nonatomic, strong) WUProject* project;
@property (nonatomic, assign) BOOL isEditMode;

@end
