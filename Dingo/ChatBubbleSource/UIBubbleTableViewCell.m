//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "RoundedImageView.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) RoundedImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {

        self.bubbleImage = [[UIImageView alloc] init];
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;
    
    CGFloat x;
    switch (type) {
        case BubbleTypeSomeoneElse:
            x = 0;
            break;
        default:
            x = self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
            break;
    }
    CGFloat y = 10;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
        self.avatarImage = [[RoundedImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 12 : self.frame.size.width - 62;
        CGFloat avatarY = self.frame.size.height - 50;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 48, 48);
        [self addSubview:self.avatarImage];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);

        if (delta > 0 ) {
            y = delta;
        }
        
        if (type == BubbleTypeSomeoneElse) x += 70;
        if (type == BubbleTypeMine || type == BubbleTypeDingo) x -= 70;
    }
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top-5, width, height);
    [self.contentView addSubview:self.customView];
    
    switch (type) {
        case BubbleTypeMine:
             self.bubbleImage.image = [[UIImage imageNamed:@"bubbleBlue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 40)];
            break;
        case BubbleTypeSomeoneElse:
            self.bubbleImage.image = [[UIImage imageNamed:@"bubbleWhite.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
            break;
        case BubbleTypeDingo:
            self.bubbleImage.image = [[UIImage imageNamed:@"bubbleGray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
            break;
        default:
            break;
    }
        
    self.bubbleImage.frame = CGRectMake(x, y-5, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
}

@end
