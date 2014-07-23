//
//  ZSTextField.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/22/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSTextField.h"

@implementation ZSTextField

UITableViewController *results;
UITableViewController *tableViewController;

NSArray *data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.text.length > 0 && self.isFirstResponder) {
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextField:)]) {
            data = [self.delegate dataForPopoverInTextField:self];
            [self provideSuggestions];
        }
        else{
            NSLog(@"ZSTextField: You have not implemented the requred methods of the protocol.");
        }
    }
    else{
        if ([tableViewController.tableView superview] != nil) {
            [tableViewController.tableView removeFromSuperview];
        }
    }
}

- (BOOL)resignFirstResponder
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [tableViewController.tableView setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [tableViewController.tableView removeFromSuperview];
                         tableViewController = nil;
                     }];
    [self handleExit];
    return [super resignFirstResponder];
}

- (void)handleExit
{
    [tableViewController.tableView removeFromSuperview];
    if ([[self delegate] respondsToSelector:@selector(textFieldShouldSelect:)]) {
        if ([[self delegate] textFieldShouldSelect:self]) {
            if ([self applyFilterWithSearchQuery:self.text].count > 0) {
                self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0] objectForKey:@"DisplayText"];
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0]];
                }
                else{
                    NSLog(@"ZSTextField: You have not implemented a method from ZSTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            }
            else if (self.text.length > 0){
                //Make sure that delegate method is not called if no text is present in the text field.
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[NSDictionary dictionaryWithObjectsAndKeys:self.text,@"DisplayText",@"NEW",@"CustomObject", nil]];
                }
                else{
                    NSLog(@"ZSTextField: You have not implemented a method from ZSTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            }
        }
    }
}


#pragma mark UITableView DataSource & Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[self applyFilterWithSearchQuery:self.text] count];
    if (count == 0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:0.0];
                         }
                         completion:^(BOOL finished){
                             [tableViewController.tableView removeFromSuperview];
                             tableViewController = nil;
                         }];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ZSResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dataForRowAtIndexPath = [[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row];
    [cell setBackgroundColor:[UIColor clearColor]];
    [[cell textLabel] setText:[dataForRowAtIndexPath objectForKey:@"DisplayText"]];
    if ([dataForRowAtIndexPath objectForKey:@"DisplaySubText"] != nil) {
        [[cell detailTextLabel] setText:[dataForRowAtIndexPath objectForKey:@"DisplaySubText"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplayText"];
    [self resignFirstResponder];
}

#pragma mark Filter Method

- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText BEGINSWITH[cd] %@", filter];
    NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
    return filteredGoods;
}

#pragma mark Popover Method(s)

- (void)provideSuggestions
{
    //Providing suggestions
    if (tableViewController.tableView.superview == nil && [[self applyFilterWithSearchQuery:self.text] count] > 0) {
        //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setCancelsTouchesInView:NO];
        [tapRecognizer setDelegate:self];
        [self.superview addGestureRecognizer:tapRecognizer];
        
        tableViewController = [[UITableViewController alloc] init];
        tableViewController.tableView.userInteractionEnabled = YES;
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        if (self.backgroundColor == nil) {
            //Background color has not been set by the user. Use default color instead.
            [tableViewController.tableView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
        }
        else{
            [tableViewController.tableView setBackgroundColor:self.backgroundColor];
        }
        
        [tableViewController.tableView setSeparatorColor:self.seperatorColor];
        if (self.popoverSize.size.height == 0.0) {
            //PopoverSize frame has not been set. Use default parameters instead.
            CGRect frameForPresentation = [self frame];
            frameForPresentation.origin.y += self.frame.size.height;
            frameForPresentation.size.height = 200;
            [tableViewController.tableView setFrame:frameForPresentation];
        }
        else{
            [tableViewController.tableView setFrame:self.popoverSize];
        }
        [[self superview] addSubview:tableViewController.tableView];
        tableViewController.tableView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:1.0];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
    }
    else{
        [tableViewController.tableView reloadData];
    }
}

- (void)tapped:(UIGestureRecognizer *)gesture
{
    
}

@end
