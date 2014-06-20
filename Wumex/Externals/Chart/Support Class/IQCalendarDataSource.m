//
//  IQCalendarDataSource.m
//  IQWidgets for iOS
//
//  Copyright 2011 EvolvIQ
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IQCalendarDataSource.h"


@interface IQCalendarSimpleDataSource () {
    NSObject<NSFastEnumeration>* data;
    NSString* title;
}
@end

@implementation IQCalendarSimpleDataSource
@synthesize title;
@synthesize startDateCallback, endDateCallback, valueCallback;

+ (IQCalendarSimpleDataSource*) dataSourceWithLabel:(NSString*)label set:(NSSet*)items
{
    IQCalendarSimpleDataSource* ds = [[IQCalendarSimpleDataSource alloc] initWithSet:items];
    ds.title = label;
    return ds;
}
+ (IQCalendarSimpleDataSource*) dataSourceWithLabel:(NSString*)label array:(NSArray*)items
{
    IQCalendarSimpleDataSource* ds = [[IQCalendarSimpleDataSource alloc] initWithArray:items];
    ds.title = label;
    return ds;
}

+ (IQCalendarSimpleDataSource*) dataSourceWithSet:(NSSet*)items
{
    IQCalendarSimpleDataSource* ds = [[IQCalendarSimpleDataSource alloc] initWithSet:items];
    return ds;
}

+ (IQCalendarSimpleDataSource*) dataSourceWithArray:(NSArray*)items
{
    IQCalendarSimpleDataSource* ds = [[IQCalendarSimpleDataSource alloc] initWithArray:items];
    return ds;
}

- (id) initWithSet:(NSSet*)items
{
    self = [super init];
    if(self != nil) {
        self->data = items;
    }
    return self;
}

- (id) initWithArray:(NSArray*)items
{
    self = [super init];
    if(self != nil) {
        self->data = items;
    }
    return self;
}

#pragma mark IQCalendarDataSource implementation

- (void) enumerateEntriesUsing:(IQCalendarDataSourceEntryCallback)enumerator from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime
{
    for(id item in (id<NSFastEnumeration>)data) {
        
        NSString *color = [item valueForKey:@"color"];
        if (!color) {
            color = @"#F18217";
        }
        NSDictionary* dict = @{@"color": color};
        
        NSDate* date = [item valueForKey:@"start"];
        NSTimeInterval tstart = [date timeIntervalSinceReferenceDate];
        
        if(tstart < endTime) {
            
            NSDate* date = [item valueForKey:@"end"];
            NSTimeInterval tend = [date timeIntervalSinceReferenceDate];
            
            if(tend > startTime) {
                NSObject<IQCalendarActivity>* activityValue = [item valueForKey:@"value"];
                enumerator(tstart, tend, activityValue, dict);
            }
        }
    }
}

@end
