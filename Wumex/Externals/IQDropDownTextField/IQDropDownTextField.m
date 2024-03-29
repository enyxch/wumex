//
//  IQDropDownTextField.m
//
//  Created by Iftekhar on 19/10/13.
//  Copyright (c) 2013 Canopus. All rights reserved.
//

#import "IQDropDownTextField.h"

@interface IQDropDownTextField ()<UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation IQDropDownTextField
{
    UIPickerView *pickerView;
    UIDatePicker *datePicker;
    UIDatePicker *timePicker;
    NSDateFormatter *dropDownDateFormatter;
    NSDateFormatter *dropDownTimeFormatter;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

-(void)initialize
{
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self setBorderStyle:UITextBorderStyleRoundedRect];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectOffset(self.bounds, self.bounds.size.width / 2 - 20, self.bounds.size.height / 2 -10.5)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.activityIndicator];
    [self.activityIndicator setContentMode:UIViewContentModeBottomRight];
    
    
    dropDownDateFormatter = [[NSDateFormatter alloc] init];
    
    datePicker = [[UIDatePicker alloc] init];
    
    pickerView = [[UIPickerView alloc] init];
    [pickerView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    
    [self setDropDownMode:IQDropDownModeTextPicker];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.activityIndicator.frame = CGRectOffset(self.bounds, self.bounds.size.width / 2 - 20, self.bounds.size.height / 2 - 10.5);
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

-(void)setDropDownMode:(IQDropDownMode)dropDownMode
{
    _dropDownMode = dropDownMode;
    
    switch (_dropDownMode)
    {
        case IQDropDownModeTextPicker:
            self.inputView = pickerView;
            break;
            
        case IQDropDownModeDatePicker:
            
            [dropDownDateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dropDownDateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            [datePicker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
            [datePicker setDatePickerMode:UIDatePickerModeDate];
            [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            
            self.inputView = datePicker;
            break;
        case IQDropDownModeTimePicker:
            
            dropDownTimeFormatter = [[NSDateFormatter alloc] init];
            [dropDownTimeFormatter setDateStyle:NSDateFormatterNoStyle];
            [dropDownTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            timePicker = [[UIDatePicker alloc] init];
            [timePicker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
            [timePicker setDatePickerMode:UIDatePickerModeTime];
            [timePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
            self.inputView = timePicker;
            break;
            
        case IQDropDownModeTextField:
            if ([pickerView numberOfRowsInComponent:0] > 0) {
                [pickerView selectRow:0 inComponent:0 animated:NO];
            }
            self.inputView = nil;
            break;
            
        default:
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _itemList.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *labelText = [[UILabel alloc] init];
    labelText.font = [UIFont boldSystemFontOfSize:20.0];
    labelText.backgroundColor = [UIColor clearColor];
    [labelText setTextAlignment:NSTextAlignmentCenter];
    [labelText setText:_itemList[row]];
    return labelText;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_itemList.count > 0) {
        [self setSelectedItem:_itemList[row]];
    }
}

-(void)dateChanged:(UIDatePicker*)dPicker
{
    [self setSelectedItem:[dropDownDateFormatter stringFromDate:dPicker.date]];
}
-(void)timeChanged:(UIDatePicker*)tPicker{
    
    [self setSelectedItem:[dropDownTimeFormatter stringFromDate:tPicker.date]];
}
-(void)setItemList:(NSArray *)itemList
{
    _itemList = itemList;
    
    if ([self.text length] == 0 && [_itemList count] > 0)
    {
        //        [self setText:[_itemList objectAtIndex:0]];
    }
    
    [pickerView reloadAllComponents];
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
    [self setSelectedItem:[dropDownDateFormatter stringFromDate:date]];
    self.text = _selectedItem;
}

- (NSDate*)selectedDate
{
    return [dropDownDateFormatter dateFromString:self.selectedItem];
}

- (NSInteger)selectedIndex
{
    return [pickerView selectedRowInComponent:0];
}

- (void)selectAtIndex:(NSInteger)index
{
    switch (_dropDownMode)
    {
        case IQDropDownModeTextPicker:
            if ([_itemList objectAtIndex:index])
            {
                _selectedItem = [_itemList objectAtIndex:index];
                self.text = _selectedItem;
                [pickerView selectRow:index inComponent:0 animated:YES];
            }
            break;
            
        case IQDropDownModeDatePicker:
        {
            break;
        }
        case IQDropDownModeTimePicker:
        {
            break;
        }
        case IQDropDownModeTextField:
        {
            break;
        }
    }
    
    if ( self.onValueChange != nil )
    {
        self.onValueChange();
    }
}

-(void)setSelectedItem:(NSString *)selectedItem
{
    switch (_dropDownMode)
    {
        case IQDropDownModeTextPicker:
            if ([_itemList containsObject:selectedItem])
            {
                _selectedItem = selectedItem;
                self.text = @"";
                [self insertText:selectedItem];
                [pickerView selectRow:[_itemList indexOfObject:selectedItem] inComponent:0 animated:YES];
            }
            break;
            
        case IQDropDownModeDatePicker:
        {
            NSDate *date = [dropDownDateFormatter dateFromString:selectedItem];
            if (date)
            {
                _selectedItem = selectedItem;
                self.text = @"";
                [self insertText:selectedItem];
                [datePicker setDate:date animated:YES];
            }
            else
            {
                NSLog(@"Invalid date or date format:%@",selectedItem);
            }
            break;
        }
        case IQDropDownModeTimePicker:
        {
            
            NSDate *date = [dropDownTimeFormatter dateFromString:selectedItem];
            if (date)
            {
                _selectedItem = selectedItem;
                self.text = @"";
                [self insertText:selectedItem];
                [datePicker setDate:date animated:YES];
            }
            else
            {
                NSLog(@"Invalid time or time format:%@",selectedItem);
            }
            break;
        }
        case IQDropDownModeTextField:
        {
            break;
        }
    }
    
    if ( self.onValueChange != nil )
    {
        self.onValueChange();
    }
}

-(void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    if (_dropDownMode == IQDropDownModeDatePicker)
    {
        _datePickerMode = datePickerMode;
        [datePicker setDatePickerMode:datePickerMode];
        
        switch (datePickerMode) {
            case UIDatePickerModeCountDownTimer:
                [dropDownDateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dropDownDateFormatter setTimeStyle:NSDateFormatterNoStyle];
                break;
            case UIDatePickerModeDate:
                [dropDownDateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dropDownDateFormatter setTimeStyle:NSDateFormatterNoStyle];
                break;
            case UIDatePickerModeTime:
                [dropDownDateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dropDownDateFormatter setTimeStyle:NSDateFormatterShortStyle];
                break;
            case UIDatePickerModeDateAndTime:
                [dropDownDateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dropDownDateFormatter setTimeStyle:NSDateFormatterShortStyle];
                break;
        }
    }
}

- (void)setDatePickerMaximumDate:(NSDate*)date
{
    if (_dropDownMode == IQDropDownModeDatePicker)
        datePicker.maximumDate = date;
}

@end
