//
//  SectionHeaderView.h
//  Dingo
//
//  Created by logan on 6/6/14.
//  Copyright (c) 2014 Xetra. All rights reserved.
//

extern const CGFloat sectionHeaderHeight;
extern const CGFloat sectionEventHeaderHeight;

@interface SectionHeaderView : UIView

+ (id)buildWithTitle:(NSString *)title
        fromXibNamed:(NSString *)name;

@end
