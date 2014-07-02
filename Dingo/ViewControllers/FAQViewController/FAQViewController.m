//
//  TermsViewController.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "FAQViewController.h"

#import "AnswerViewController.h"
#import "QuestionCell.h"

static const NSUInteger questionsCount = 3;
static const CGFloat titleHeight = 80;
static const CGFloat questionCellHeight = 50;

@interface FAQViewController () <UITableViewDataSource, UITabBarDelegate>

@end

@implementation FAQViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return questionsCount + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row ? questionCellHeight : titleHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"IconCell"];
    }
    
    QuestionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"QuestionCell"];;
    cell.question = [NSString stringWithFormat:@"Question %ld", (long)indexPath.row];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnswerViewController *vc = segue.destinationViewController;
    QuestionCell *cell = (QuestionCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    vc.question = cell.question;
}

#pragma mark - UIActions

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
