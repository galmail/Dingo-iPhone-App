//
//  EventView.m
//  Dingo
//
//  Created by logan on 6/2/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "TicketCell.h"

#import "DiscountView.h"
#import "DataManager.h"

const CGFloat featureCellHeight = 170;

@interface TicketCell () {
    Event* event;
}

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UILabel *startPriceLabel;
@property (nonatomic, weak) IBOutlet UILabel *ticketsCountLabel;
@property (nonatomic, weak) IBOutlet DiscountView *discountView;

@property (nonatomic) float price;


@end

@implementation TicketCell

#pragma mark - Setters

- (void)awakeFromNib {
    [super awakeFromNib];
 
    if ([NSStringFromClass([self class]) isEqual:@"TicketCell"]) {
        self.startPriceLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:36];
    }
    
    if ([NSStringFromClass([self class]) isEqual:@"ManageListsCell"]) {
        self.startPriceLabel.font = [UIFont fontWithName:@"SourceSansPro-Regular" size:18];
    }
}

- (void)setPrice:(float)price {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setAllowsFloats:YES];
    [formatter setMaximumFractionDigits:2];
    
    NSString *strPrice = [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
    
    if ([NSStringFromClass([self class]) isEqual:@"TicketCell"]) {
    
        if ([event.tickets intValue] > 1) {
            self.startPriceLabel.text = [NSString stringWithFormat:@"from £%@", strPrice];
        } else {
            self.startPriceLabel.text = [NSString stringWithFormat:@"£%@", strPrice];
        }
    } else {    
        
        if (fmodf(price, 1) !=0)
            self.startPriceLabel.text = [NSString stringWithFormat:@"£%.2f", price];
        else
            self.startPriceLabel.text = [NSString stringWithFormat:@"£%@", strPrice];
        
    }
}

- (void)setTickets:(uint)tickets {
    self.ticketsCountLabel.text = tickets > 10 ? @"10+" : [NSString stringWithFormat:@"%d", tickets];
}

#pragma mark - Custom

+ (id)buildWithData:(Event *)data {
    
    TicketCell *cell = [[TicketCell alloc] init];
    [cell loadUIFromXib];
    [cell buildWithData:data];
    return cell;
}

- (void)buildWithData:(Event *)data {
    [super buildWithData:data];
    
    event = data;
    
    self.price = lroundf([data.fromPrice floatValue]);
    self.discountView.discount = 0;//[data[@"discount"] intValue];
    self.tickets = [data.tickets intValue];
}

- (void)buildWithTicketData:(Ticket *)data {
//    [super buildWithData:data];
    self.price = [data.price floatValue];
    self.discountView.discount = 0;//[data[@"discount"] intValue];
    self.tickets = [data.number_of_tickets intValue];
}

#pragma mark - Private

- (void)loadUIFromXib {
    if ([self.contentView.subviews containsObject:self.view]) {
        return;
    }
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    self.frame = self.contentView.frame;
    [self.contentView addSubview:self.view];
}

@end
