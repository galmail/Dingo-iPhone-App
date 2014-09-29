//
//  TicketAlertCell
//  Dingo
//
//  Created by Tigran Aslanyan on 21.08.14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "TicketAlertCell.h"
#import "DingoUISettings.h"
#import "DataManager.h"

@interface TicketAlertCell () {
    Alert* alert;
}
@property (nonatomic, weak) IBOutlet UILabel *lblDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;

@end

@implementation TicketAlertCell

#pragma mark - Setters

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lblDescriptionLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:17];
    self.lblDescription.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:18];
    
}



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
        //handles ios6 and earlier
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
        {
            //we'll add a view to cover the default control as the image used has a transparent BG
            UIView *backgroundCoverDefaultControl = [[UIView alloc] initWithFrame:CGRectMake(0,0, 64, 33)];
            [backgroundCoverDefaultControl setBackgroundColor:[UIColor whiteColor]];//assuming your view has a white BG
            [[subview.subviews objectAtIndex:0] addSubview:backgroundCoverDefaultControl];
            subview.backgroundColor = [UIColor colorWithRed:220. / 255
                                                      green:55. / 255
                                                       blue:55. / 255
                                                      alpha:1];
        }
        //the rest handles ios7
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

- (void)buildWithData:(Alert *)data {
    //    [super buildWithData:data];
    
    alert = data;
    Event *event = [[DataManager shared] eventByID:alert.event_id];
    
    self.lblDescription.text = event.name;
}



#pragma mark - Private

- (void)loadUIFromXib {
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    self.frame = self.contentView.frame;
}

@end
