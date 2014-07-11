//
//  HomeViewController.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "EventsViewController.h"

#import "TicketCell.h"
#import "CategorySelectionCell.h"
#import "DataManager.h"
#import "DingoUtilites.h"
#import "SectionHeaderView.h"
#import "TicketsViewController.h"
#import "DingoUISettings.h"

static const CGSize iconSize = {28, 32};
static const CGFloat categoriesHeight = 140;

@implementation EventsViewController{
    NSMutableArray * tipBGImages;
    NSMutableArray * tipTextImages;
    
    UIButton * btnContinue;
    UIView * tipsView;
    int tipIndex;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBar];
    
    if (1==1) {
        [self setupTips];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.parentViewController.navigationItem.titleView = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section ? eventCellHeight : categoriesHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section)  {
        return nil;
    }
    
    NSDate *date = [[DataManager shared] eventGroupDateByIndex:section - 1];
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
    
    return [[DataManager shared] eventsCountWithGroupIndex:section - 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[DataManager shared] eventsGroupsCount] + 1;
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
    TicketsViewController *vc = (TicketsViewController *)segue.destinationViewController;
    NSIndexPath *selectedCellPath = [self adjustedPath:[self.tableView indexPathForSelectedRow]];
    vc.eventData = [[DataManager shared] eventDescriptionByIndexPath:selectedCellPath];
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
    
    NSDictionary *data = [[DataManager shared] eventDescriptionByIndexPath:path];
    [cell buildWithData:data];
    return cell;
}

- (UITableViewCell *)buildCategoriesCell {
    static NSString * const cellId = @"CategoriesCell";
    CategorySelectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    [cell buildByUserPreferences];
    return cell;
}

- (NSIndexPath *)adjustedPath:(NSIndexPath *)path {
    return [NSIndexPath indexPathForRow:path.row inSection:path.section - 1];
}

#pragma mark

- (void)setupTips{
    tipsView  = [[UIView alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].frame];
    
    tipBGImages = [NSMutableArray new];
    tipTextImages = [NSMutableArray new];
    tipIndex = 0;
    
    for (int i=1; i<5; i++) {
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcome%dBG",i]]];
        
        img.frame = [[[UIApplication sharedApplication] delegate] window].frame;
        
        [tipsView addSubview:img];
        if (i>1) {
            img.alpha = 0;
        }
        
        [tipBGImages addObject:img];
    }
    
    //message BG
    UIImageView * imgMessageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageBG"]];
    imgMessageBG.frame = CGRectMake(40, ([[[UIApplication sharedApplication] delegate] window].frame.size.height-214)/2-50, 240, 214);
    [tipsView addSubview:imgMessageBG];
    
    
    
    NSArray * heights = @[@180,@140,@160,@180];
    
    for (int i=1; i<5; i++) {
        
        UIImageView * imgText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"welcomeText%d",i]]];
        imgText.frame = CGRectMake(0, (tipsView.frame.size.height-[heights[i-1] integerValue])/2-70, 320, [heights[i-1] integerValue]);
        
        [tipsView addSubview:imgText];
        if (i>1) {
            imgText.alpha = 0;
        }
        
        [tipTextImages addObject:imgText];
    }
    
    
    
    btnContinue = [[UIButton alloc] initWithFrame:CGRectMake(50, 280, 220, 40)];
    [btnContinue setImage:[UIImage imageNamed:@"btnContinue"] forState:UIControlStateNormal];
    [btnContinue addTarget:self action:@selector(btnContinueTap:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:tipsView];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:btnContinue];
}

- (IBAction)btnContinueTap:(id)sender{
    if (tipIndex==2) {
        [btnContinue setImage:[UIImage imageNamed:@"btnFinish"] forState:UIControlStateNormal];
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (tipIndex!=3) {
                             ((UIImageView*)tipBGImages[tipIndex]).alpha = 0;
                             ((UIImageView*)tipTextImages[tipIndex]).alpha = 0;
                         }
                         if (tipIndex<3) {
                             ((UIImageView*)tipBGImages[tipIndex+1]).alpha = 1;
                             ((UIImageView*)tipTextImages[tipIndex+1]).alpha = 1;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         if(finished){
                             tipIndex++;
                             if (tipIndex==4) {
                                 [UIView animateWithDuration:0.3
                                                  animations:^{
                                                      tipsView.alpha = 0;
                                                      btnContinue.alpha = 0;
                                                  }
                                                  completion:^(BOOL finished){
                                                      if(finished){
                                                          [tipsView removeFromSuperview];
                                                          [btnContinue removeFromSuperview];
                                                          tipBGImages = nil;
                                                          tipTextImages = nil;
                                                      }
                                                      
                                                  }];
                                 
                             }
                         }
                     }];
}
@end
