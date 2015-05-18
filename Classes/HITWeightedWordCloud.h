//
//  HITWeightedWordCloud.h
//
//  Created by Maciej Swic on 05/05/15.
//  Copyright (c) 2015 Maciej Swic.

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//  to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions
//  of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
//  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HITWeightedWordCloudOrigin) {
    HITWeightedWordCloudOriginRandom,
    HITWeightedWordCloudOriginTopLeft
};

@interface HITWeightedWordCloud : NSObject

/**
 *  Screen scale.
 */
@property (nonatomic) CGFloat scale;

/**
 *  The size to render.
 */
@property (nonatomic) CGSize size;

/**
 *  The background color. Defaults to UIColor.clearColor.
 */
@property (nonatomic, copy) UIColor *backgroundColor;

/**
 *  Text color.
 */
@property (nonatomic, copy) UIColor *textColor;

/**
 *  Minimum font size. Defaults to UIFont.systemFontSize * 0.6
 */
@property (nonatomic) CGFloat minFontSize;

/**
 *  Max font size. Defaults to UIFont.systemFontSize * 1.4
 */
@property (nonatomic) CGFloat maxFontSize;

/**
 *  The origin for the words.
 */
@property (nonatomic) HITWeightedWordCloudOrigin origin;

/**
 *  Init
 *
 *  @param size The size of the word cloud.
 *
 *  @return A HITWordCloud.
 */
- (instancetype)initWithSize:(CGSize)size;

/**
 *  Calculates the minimum size for the given dictionary. Only works with HITWeightedWordCloudOriginTopLeft.
 *
 *  @param wordDictionary A dictionary with your words. The keys should be the words (NSString) and the values their weight (NSNumber).
 *
 *  @return A CGSize that will fit all the words.
 */
- (CGSize)minimumSizeWithWords:(NSDictionary *)wordDictionary;

/**
 *  Renders a word cloud.
 *
 *  @param wordDictionary A dictionary with your words. The keys should be the words (NSString) and the values their weight (NSNumber).
 *
 *  @return A UIImage with the rendered word cloud.
 */
- (UIImage *)imageWithWords:(NSDictionary *)wordDictionary;

@end
