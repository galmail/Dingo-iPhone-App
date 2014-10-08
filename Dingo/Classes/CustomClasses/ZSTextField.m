//
//  ZSTextField.m
//  Dingo
//
//  Created by Asatur Galstyan on 7/22/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "ZSTextField.h"

@interface ZSTextField () {


    
    NSArray *data;

}
@end

@implementation ZSTextField

UITableViewController *results;
UITableViewController *tableViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.applyFilter = YES;
}

- (void) showToolbarWithDone {
    
    UIView * keyboardHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    keyboardHeader.backgroundColor = [UIColor darkGrayColor];
    UIImage *image = [UIImage imageNamed:@"barButton"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 12, 0.0, 12)];
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(240, 6, 70, 33)];
    
    [btnDone setBackgroundImage:image forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    [btnDone addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyboardHeader addSubview:btnDone];
    self.inputAccessoryView = keyboardHeader;
    
}

- (void)closeKeyboard:(id)sender {
    
    if  ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

- (void) showToolbarWithPrev:(BOOL)prevEnabled next:(BOOL)nextEnabled done:(BOOL)doneEnabled {
    
    UIView * keyboardHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    keyboardHeader.backgroundColor = [UIColor darkGrayColor];

    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(240, 6, 70, 33)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    [btnDone addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyboardHeader addSubview:btnDone];
    
    UIButton *btnPrev = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPrev setFrame:CGRectMake(10, 6, 80, 33)];
    [btnPrev setTitle:@"Previous" forState:UIControlStateNormal];
    btnPrev.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    btnPrev.tag = 1;
    [btnPrev addTarget:self action:@selector(nextPrevHandlerDidChange:) forControlEvents:UIControlEventTouchUpInside];
    [keyboardHeader addSubview:btnPrev];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(90, 6, 70, 33)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    btnNext.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    btnNext.tag = 2;
    [btnNext addTarget:self action:@selector(nextPrevHandlerDidChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyboardHeader addSubview:btnNext];
    self.inputAccessoryView = keyboardHeader;
    
}

- (void)nextPrevHandlerDidChange:(id)sender {
    if (!self.delegate) return;
    
    switch ([(UIBarButtonItem*)sender tag])
    {
        case 1:
            if ([self.delegate respondsToSelector:@selector(previousDidPressed:)]) {
                [self.delegate previousDidPressed:self];
            }
            break;
        case 2:
            if ([self.delegate respondsToSelector:@selector(nextDidPressed:)]) {
                [self.delegate nextDidPressed:self];
            }
            break;
        default:
            break;
    }
}

- (void) setAutocompleteData:(NSArray*)autoCompleteData {
    data =  autoCompleteData;
    self.clipsToBounds = NO;
    [self provideSuggestions];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.text.length > 0 && self.isFirstResponder) {
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextField:)]) {
            data = [self.delegate dataForPopoverInTextField:self];
            if (data) {
                [self provideSuggestions];
            }
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
    NSInteger count = [[self applyFilterWithSearchQuery:self.text] count];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.userInteractionEnabled = YES;
    
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
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [tableViewController.tableView setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [tableViewController.tableView removeFromSuperview];
                         tableViewController = nil;
                     }];
    [self handleExit];
}

#pragma mark Filter Method

- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter
{
    if (self.applyFilter) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText contains[cd] %@", filter];
        NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
        return filteredGoods;

    }
    
    return data;
}

#pragma mark Popover Method(s)

- (void)provideSuggestions
{
    //Providing suggestions
    if (tableViewController.tableView.superview == nil && [[self applyFilterWithSearchQuery:self.text] count] > 0) {
        
        tableViewController = [[UITableViewController alloc] init];
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
        
        UIView *superView = [self superview];
        CGRect boundViewframe = [self frame];
        
        if ([superView isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]){
            superView = superView.superview.superview.superview.superview;
            boundViewframe = [superView convertRect:boundViewframe fromView:self];
        }
        
        if (self.popoverSize.size.height == 0.0) {
            //PopoverSize frame has not been set. Use default parameters instead.
            CGRect frameForPresentation = [self frame];
            frameForPresentation.origin.y += boundViewframe.size.height;
            frameForPresentation.size.height = 200;
            [tableViewController.tableView setFrame:frameForPresentation];
        }
        else{
            CGRect frameForPresentation = self.popoverSize;
            frameForPresentation.origin.y += boundViewframe.origin.y;
            
            [tableViewController.tableView setFrame:frameForPresentation];
            [tableViewController.tableView setContentSize:self.popoverSize.size];
        }
        
        [superView addSubview:tableViewController.tableView];

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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    
    CGPoint pointForTargetView = [tableViewController.tableView convertPoint:point fromView:self];
    
    if (CGRectContainsPoint(tableViewController.tableView.bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [tableViewController.tableView hitTest:pointForTargetView withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
}

@end
