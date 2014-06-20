//
//  WUTaskViewController.h
//  Wumex
//
//  Created by Nicolas Bonnet on 18.06.14.
//  Copyright (c) 2014 Nicolas Bonnet. All rights reserved.
//

#import "WUViewController.h"

#import "WUTask.h"
#import "IQTextView.h"
#import "IQDropDownTextField.h"

@interface WUTaskViewController : WUViewController <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;

@property (weak, nonatomic) IBOutlet UILabel *labelFromProject;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *pickerFromProject;
@property (weak, nonatomic) IBOutlet UILabel *labelInList;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *pickerInList;

@property (weak, nonatomic) IBOutlet UILabel *labelStartDate;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *pickerStartDate;
@property (weak, nonatomic) IBOutlet UILabel *labelEndDate;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *pickerEndDate;

@property (weak, nonatomic) IBOutlet UILabel *labelEstimatedTime;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEstimatedTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeSpent;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTimeSpent;

@property (weak, nonatomic) IBOutlet IQTextView *textViewDescription;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *listConstraintTextFieldHeight;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *listOfTextField;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceBetween;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTextFieldEndDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightTextViewDescription;

@property (nonatomic, strong) WUTask* task;
@property (nonatomic, strong) WUTask* previousTask;
@property (nonatomic, assign) BOOL isEditMode;

@end
