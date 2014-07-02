//
//  SectionHeaderView.m
//  Dingo
//
//  Created by logan on 6/6/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

#import "SectionHeaderView.h"

const CGFloat sectionHeaderHeight = 20;
const CGFloat sectionEventHeaderHeight = 30;

@interface SectionHeaderView ()

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation SectionHeaderView

+ (id)buildWithTitle:(NSString *)title fromXibNamed:(NSString *)name {
    SectionHeaderView *header = [[SectionHeaderView alloc] init];
    [[NSBundle mainBundle] loadNibNamed:name
                                  owner:header
                                options:nil];
    header.frame = header.view.frame;
    [header addSubview:header.view];
    
    header.titleLabel.text = title;
    return header;
}

@end
