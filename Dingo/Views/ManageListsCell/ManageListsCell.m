//
//  ManageListsCell.m
//  Dingo
//
//  Created by logan on 6/13/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "ManageListsCell.h"
#import "Ticket.h"
#import "DingoUISettings.h"
#import "DataManager.h"

@interface ManageListsCell ()

@end

@implementation ManageListsCell

#pragma mark - Setters


#pragma mark - Custom

#pragma mark - Custom

-(void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    if((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask){
        [self recurseAndReplaceSubViewIfDeleteConfirmationControl:self.subviews];
        [self performSelector:@selector(recurseAndReplaceSubViewIfDeleteConfirmationControl:) withObject:self.subviews afterDelay:0];
    }
}

-(void)recurseAndReplaceSubViewIfDeleteConfirmationControl:(NSArray*)subviews{
    
    for (UIView *subview in subviews)
    {
        
        if ([subview isKindOfClass:[UIScrollView class]]) {
            
        }
        
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationButton"])
        {
            subview.backgroundColor = [UIColor colorWithRed:220. / 255
                                                      green:55. / 255
                                                       blue:55. / 255
                                                      alpha:1];
            
            for(UIView* view in subview.subviews){
                if([view isKindOfClass:[UILabel class]]){
                    ((UILabel*)view).font = [DingoUISettings fontWithSize:12];
                    ((UILabel*)view).text = @"Remove";
                    ((UILabel*)view).numberOfLines = 2;
                    ((UILabel*)view).textColor = [UIColor whiteColor];
                }
            }
        }
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"])
        {
            for(UIView* innerSubView in subview.subviews){
                if(![innerSubView isKindOfClass:[UIButton class]]){
                    [innerSubView removeFromSuperview];
                }
            }
        }
        if([subview.subviews count]>0){
            [self recurseAndReplaceSubViewIfDeleteConfirmationControl:subview.subviews];
        }
        
    }
}


- (void)buildWithTicketData:(Ticket *)data {
    [super buildWithTicketData:data];
    
    Event *event = [[DataManager shared] eventByID:data.event_id];
    
    [self buildWithData:event];
    
//    self.offers = [data[@"offers"] floatValue];
}

@end