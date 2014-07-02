//
//  DiscountView.m
//  Dingo
//
//  Created by logan on 6/9/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "DiscountView.h"

#import "DingoUISettings.h"

static const CGFloat badgeHeight = 16;
static const CGFloat badgeYShift = badgeHeight;

@implementation DiscountView


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    if (!self.discount) {
        return;
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [DingoUISettings titleBackgroundColor].CGColor);
    
    CGSize sz = self.bounds.size;
    CGSize badgeSize = CGSizeMake(sz.width + sz.height, badgeHeight);
    CGContextTranslateCTM(ctx, sz.width / 2, sz.height / 2);
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextRotateCTM(ctx, M_PI_4);
    
    CGRect badgeRect = CGRectMake(-badgeSize.width / 2, -badgeSize.height / 2 + badgeYShift, badgeSize.width, badgeSize.height);
    CGContextFillRect(ctx, badgeRect);
    CGContextRestoreGState(ctx);

    CGContextRotateCTM(ctx, -M_PI_4);
    CGContextSetFillColorWithColor(ctx, [DingoUISettings foregroundColor].CGColor);
    [self drawString:[NSString stringWithFormat:@"%ld%% off", (long)self.discount]];
}

#pragma mark - Setters

- (void)setDiscount:(NSInteger)discount {
    _discount = discount;
    [self setNeedsDisplay];
}

#pragma mark - Private

- (void)drawString:(NSString *)string {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:12];
    CGSize sz = self.bounds.size;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [DingoUISettings foregroundColor]};
    
    CGSize textSize = [string boundingRectWithSize:sz
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil].size;
    
    CGRect textRect = CGRectMake(-textSize.width / 2, -textSize.height / 2 - badgeYShift, textSize.width, textSize.height);
    
    [string drawInRect:textRect withAttributes:attributes];
}

@end
