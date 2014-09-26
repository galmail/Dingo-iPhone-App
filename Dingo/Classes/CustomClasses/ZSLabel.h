//
//  ZSLabel.h
//  Dingo
//
//  Created by Asatur Galstyan on 9/26/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef enum
{
	RTTextAlignmentRight = kCTRightTextAlignment,
	RTTextAlignmentLeft = kCTLeftTextAlignment,
	RTTextAlignmentCenter = kCTCenterTextAlignment,
	RTTextAlignmentJustify = kCTJustifiedTextAlignment
} RTTextAlignment;

typedef enum
{
	RTTextLineBreakModeWordWrapping = kCTLineBreakByWordWrapping,
	RTTextLineBreakModeCharWrapping = kCTLineBreakByCharWrapping,
	RTTextLineBreakModeClip = kCTLineBreakByClipping,
}RTTextLineBreakMode;

@protocol ZSLabelDelegate <NSObject>

@optional
- (void)ZSLabel:(id)ZSLabel didSelectLinkWithURL:(NSURL*)url;
@end

@interface ZSLabelComponent : NSObject
@property (nonatomic, assign) int componentIndex;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tagLabel;
@property (nonatomic) NSMutableDictionary *attributes;
@property (nonatomic, assign) int position;

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
- (id)initWithTag:(NSString*)aTagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes;
+ (id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes;

@end

@interface ZSLabelExtractedComponent : NSObject
@property (nonatomic, strong) NSMutableArray *textComponents;
@property (nonatomic, copy) NSString *plainText;
+ (ZSLabelExtractedComponent*)ZSLabelExtractComponentsWithTextComponent:(NSMutableArray*)textComponents plainText:(NSString*)plainText;
@end

@interface ZSLabel : UIView
@property (nonatomic, copy) NSString *text, *plainText, *highlightedText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSDictionary *linkAttributes;
@property (nonatomic, strong) NSDictionary *selectedLinkAttributes;
@property (nonatomic, unsafe_unretained) id<ZSLabelDelegate> delegate;
@property (nonatomic, copy) NSString *paragraphReplacement;
@property (nonatomic, strong) NSMutableArray *textComponents, *highlightedTextComponents;
@property (nonatomic, assign) RTTextAlignment textAlignment;
@property (nonatomic, assign) CGSize optimumSize;
@property (nonatomic, assign) RTTextLineBreakMode lineBreakMode;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) int currentSelectedButtonComponentIndex;
@property (nonatomic, assign) CFRange visibleRange;
@property (nonatomic, assign) BOOL highlighted;

// set text
- (void)setText:(NSString*)text;
+ (ZSLabelExtractedComponent*)extractTextStyleFromText:(NSString*)data paragraphReplacement:(NSString*)paragraphReplacement;
// get the visible text
- (NSString*)visibleText;

// alternative
// from susieyy http://github.com/susieyy
// The purpose of this code is to cache pre-create the textComponents, is to improve the performance when drawing the text.
// This improvement is effective if the text is long.
- (void)setText:(NSString *)text extractedTextComponent:(ZSLabelExtractedComponent*)extractedComponent;
- (void)setHighlightedText:(NSString *)text extractedTextComponent:(ZSLabelExtractedComponent*)extractedComponent;
- (void)setText:(NSString *)text extractedTextStyle:(NSDictionary*)extractTextStyle __attribute__((deprecated));
+ (NSDictionary*)preExtractTextStyle:(NSString*)data __attribute__((deprecated));

- (CGFloat)frameHeight:(CTFrameRef)frame;

@end
