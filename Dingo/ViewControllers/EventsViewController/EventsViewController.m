//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "EventsViewController.h"

#import "TicketCell.h"

#import "DataManager.h"
#import "DingoUtilites.h"
#import "SectionHeaderView.h"
#import "TicketsViewController.h"
#import "DingoUISettings.h"
#import "AppManager.h"
#import "ZSLoadingView.h"

static const CGSize iconSize = {28, 32};
static const CGFloat categoriesHeight = 110;

@implementation EventsViewController{
    
    UIButton * btnContinue;
    UIView * tipsView;
    UIImageView *msgView;
    int tipIndex;
    
    NSArray *selectedCategories;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    selectedCategories = [[[DataManager shared] allCategories] valueForKey:@"category_id"];
 
    ZSLoadingView *loadingView =[[ZSLoadingView alloc] initWithLabel:@"Loading events ..."];
    [loadingView show];
    
    [[DataManager shared] allCategoriesWithCompletion:^(BOOL finished) {
        if (!selectedCategories.count) {
            selectedCategories = [[[DataManager shared] allCategories] valueForKey:@"category_id"];
        }
        [[DataManager shared] allEventsWithCompletion:^(BOOL finished) {
            [self.tableView reloadData];
            [loadingView hide];
            if ([[AppManager sharedManager] justInstalled]) {
                [self setupTips];
            }
        }];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.parentViewController.navigationItem.titleView = nil;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    
    [self.refreshControl beginRefreshing];
    [[DataManager shared] allCategoriesWithCompletion:^(BOOL finished) {
        [[DataManager shared] allEventsWithCompletion:^(BOOL finished) {
            [self.tableView reloadData];
            
            if ([[AppManager sharedManager] justInstalled]) {
                [self setupTips];
                
                
            }
            [self.refreshControl endRefreshing];
        }];
        
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section ? eventCellHeight : categoriesHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section)  {
        return nil;
    }
    
    NSDate *date = [[DataManager shared] eventGroupDateByIndex:section - 1 categories:selectedCategories];
    NSString *title = [DingoUtilites eventFormattedDate:date];
    static NSString * const sectionHeader = @"SectionHeaderView";
    return [SectionHeaderView buildWithTitle:title fromXibNamed:sectionHeader];
    
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 0;
    }
    
    return sectionHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return 1;
    }
    
    return [[DataManager shared] eventsCountWithGroupIndex:section - 1 categories:selectedCategories];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] eventsGroupsCountForCategories:selectedCategories] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        return [self buildCategoriesCell];
    }
    
    NSIndexPath *path = [self adjustedPath:indexPath];
    return [self buildEventCellForIndexPath:path];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedCellPath = [self adjustedPath:[self.tableView indexPathForSelectedRow]];
    Event* event= [[DataManager shared] eventDescriptionByIndexPath:selectedCellPath categories:selectedCategories];
    
    if ([event.tickets intValue] > 1) {
        TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
        vc.eventData = event;
    } else {
        // TODO: need to show ticket detail
        
        TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
        vc.eventData = event;
    }

}

#pragma mark - Private

- (void)setupNavigationBar {
    UIImageView *navigationImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconSize.width, iconSize.height)];
    navigationImage.image = [UIImage imageNamed:@"dingo_logo.png"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize.width, iconSize.height)];
    [workaroundImageView addSubview:navigationImage];
    self.parentViewController.navigationItem.titleView = workaroundImageView;
}

- (UITableViewCell *)buildEventCellForIndexPath:(NSIndexPath *)path {
    static NSString * const cellId = @"TicketsCell";
    TicketCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    [cell loadUIFromXib];
    
    Event *data = [[DataManager shared] eventDescriptionByIndexPath:path categories:selectedCategories];
    [cell buildWithData:data];
    return cell;
}

- (UITableViewCell *)buildCategoriesCell {
    static NSString * const cellId = @"CategoriesCell";
    CategorySelectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    cell.delegate = self;
    [cell buildByUserPreferences];
    [cell refresh];
    cell.selectedCategories = [selectedCategories mutableCopy];
    
    return cell;
}

- (NSIndexPath *)adjustedPath:(NSIndexPath *)path {
    return [NSIndexPath indexPathForRow:path.row inSection:path.section - 1];
}

#pragma mark

- (void)setupTips{
    
    tipsView  = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds ];
    tipIndex = 1;
    
    UIImageView *imgTipBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcome%dBG%@", tipIndex, IS_IPHONE_5 ? @"-568h" : @""]]];
    imgTipBG.tag = 111;
    [tipsView addSubview:imgTipBG];
   
    //message BG
    msgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageBG"]];
    msgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-20);
    msgView.userInteractionEnabled = YES;
    [tipsView addSubview:msgView];
    
    UIImageView *imgText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcomeText%d",tipIndex]]];
    imgText.contentMode = UIViewContentModeScaleAspectFit;
    imgText.center = CGPointMake(msgView.frame.size.width/2, msgView.frame.size.height/2-20);
    imgText.tag = 222;
    [msgView addSubview:imgText];
    
    btnContinue = [[UIButton alloc] initWithFrame:CGRectMake(10, 160, 220, 40)];
    [btnContinue setImage:[UIImage imageNamed:@"btnContinue"] forState:UIControlStateNormal];
    [btnContinue addTarget:self action:@selector(btnContinueTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [msgView addSubview:btnContinue];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:tipsView];
    
}

- (IBAction)btnContinueTap:(id)sender{
    if (tipIndex==3) {
        [btnContinue setImage:[UIImage imageNamed:@"btnFinish"] forState:UIControlStateNormal];
    }
    
    UIImageView *imgBG = (UIImageView*)[tipsView viewWithTag:111];
    UIImageView *imgText = (UIImageView*)[msgView viewWithTag:222];
    [UIView animateWithDuration:0.15 animations:^{
        
        imgBG.alpha = 0.7;
        imgText.alpha = 0.7;
        
    } completion:^(BOOL finished) {
        tipIndex++;
        
        if (tipIndex == 5) {
            [UIView animateWithDuration:0.15 animations:^{
                tipsView.alpha = 0;
            } completion:^(BOOL finished) {
                [tipsView removeFromSuperview];
                tipsView = nil;
                msgView = nil;
                btnContinue = nil;
            }];
        } else {
        
            imgBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"welcome%dBG%@", tipIndex, IS_IPHONE_5 ? @"-568h" : @""]];
            imgText.image = [UIImage imageNamed:[NSString stringWithFormat:@"welcomeText%d", tipIndex]];
            [UIView animateWithDuration:0.15 animations:^{
                imgBG.alpha = 1;
                imgText.alpha = 1;
            }];
        }
    }];
}

#pragma mark CategorySelection methods 

-(void)didSelectedCategories:(NSArray *)selectionArray {
    selectedCategories = selectionArray;
    [self.tableView reloadData];
}

@end
