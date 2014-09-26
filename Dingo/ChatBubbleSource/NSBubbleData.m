//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>
#import "DingoUISettings.h"
#import "ZSLabel.h"

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {7, 10, 7, 15};
const UIEdgeInsets textInsetsSomeone = {7, 10, 7, 15};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type delegate:(id)delegate
{
    return [[NSBubbleData alloc] initWithText:text date:date type:type delegate:delegate];
}

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type delegate:(id)delegate
{
    UIFont *font = [DingoUISettings fontWithSize:[UIFont systemFontSize]];
    
    
    CGRect frame = [(text ? text : @"") boundingRectWithSize:CGSizeMake(200, 9999)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    ZSLabel *label = [[ZSLabel alloc] initWithFrame:frame];
    [label setText:text];
    frame.size.height = label.optimumSize.height;
    label.frame = frame;
    label.delegate = delegate;
    
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.text = (text ? text : @"");
//    label.font = font;
//    label.backgroundColor = [UIColor clearColor];
//    
//    switch (type) {
//        case BubbleTypeMine:
//        case BubbleTypeDingo:
//            label.textColor = [UIColor whiteColor];
//            break;
//        case BubbleTypeSomeoneElse:
//            label.textColor = [UIColor darkGrayColor];
//            break;
//        default:
//            break;
//    }
//
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets];
}


- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    UIFont *font = [DingoUISettings fontWithSize:[UIFont systemFontSize]];

    
    CGRect frame = [(text ? text : @"") boundingRectWithSize:CGSizeMake(200, 9999)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    switch (type) {
        case BubbleTypeMine:
        case BubbleTypeDingo:
            label.textColor = [UIColor whiteColor];
            break;
        case BubbleTypeSomeoneElse:
            label.textColor = [UIColor darkGrayColor];
            break;
        default:
            break;
    }
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {40, 20, 20, 20};
const UIEdgeInsets imageInsetsSomeone = {20, 20, 20, 20};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithImage:image date:date type:type];
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    CGSize size = image.size;
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];       
}

#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets  
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

@end
