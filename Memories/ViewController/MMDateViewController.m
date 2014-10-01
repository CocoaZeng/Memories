//
//  MMDateViewController.m
//  Memories
//
//  Created by Zeng Wang on 5/2/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMDateViewController.h"
#import "MMTableViewCellPickDate.h"
#import "MMSharedClasses.h"
#import "constants.h"

@interface MMDateViewController ()
@property (strong, nonatomic) MMTableViewCellPickDate *startDateCell;
@property (strong, nonatomic) MMTableViewCellPickDate *endDateCell;

@end

@implementation MMDateViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.startDate = [[NSString alloc] init];
        self.endDate = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init navigation items
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveDates)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDates)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.title = @"Starts & Ends";
    
    // Init tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    [self.tableView setFrame:CGRectMake(0, 50, 320, 170)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundView:nil];
    [self.view addSubview:self.tableView];
    [self.tableView setScrollEnabled:NO];
    
    // Init dataPicker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 350, 320, 170)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setDate:[NSDate date]];
    [self.datePicker addTarget:self
                   action:@selector(changeDateInLabel)
         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    
    // Register UITableViewCell class
    UINib *nibDateCell = [UINib nibWithNibName:@"MMTableViewCellPickDate" bundle:nil];
    [[self tableView] registerNib:nibDateCell forCellReuseIdentifier:@"dateTableViewCell"];
}

- (void)saveDates
{
    if (nil != self.trip) {
        self.trip.tripStartDate = self.startDate;
        self.trip.tripEndDate = self.endDate;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelDates
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Set background view color to yellow
    UIColor *yel=[[UIColor alloc]initWithRed:240/255.0 green:197/255.0 blue:67/255.0 alpha:1.0];
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:yel];
    
    if ([indexPath row] == 0)
    {
        self.startDateCell = [self.tableView dequeueReusableCellWithIdentifier:@"dateTableViewCell"];

        self.startDateCell.titleLabel.text = @"Starts";
        self.startDateCell.dateLabel.text = self.startDate;
        [self.startDateCell setSelectedBackgroundView:bgColorView];
        return self.startDateCell;
    }
    else
    {
        self.endDateCell = [self.tableView dequeueReusableCellWithIdentifier:@"dateTableViewCell"];

        self.endDateCell.titleLabel.text = @"Ends";
        self.endDateCell.dateLabel.text = self.endDate;
        [self.endDateCell setSelectedBackgroundView:bgColorView];
        if (!self.endDateCell.selected) {
            self.startDateCell.selected = YES;
        }

        return self.endDateCell;
    }

}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.endDateCell.selected) {
        self.startDateCell.selected = NO;
    }
    MMTableViewCellPickDate *cell = (MMTableViewCellPickDate *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *dateString = cell.dateLabel.text;
    NSDate *date = [[MMSharedClasses sharedClasses] dateFormattedFromString:dateString];
    [self.datePicker setDate:date animated:YES];
}

#pragma UIPickerViewDelegate
- (void)changeDateInLabel
{
    NSString *selectedDateString = [[MMSharedClasses sharedClasses] stringFormattedFromDate:self.datePicker.date];
    if (self.startDateCell && self.startDateCell.selected) {
        self.startDateCell.dateLabel.text = selectedDateString;
        self.startDate = selectedDateString;
    }
    else if (self.endDateCell && self.endDateCell.selected) {
        self.endDateCell.dateLabel.text = selectedDateString;
        self.endDate = selectedDateString;
    }
}

@end
