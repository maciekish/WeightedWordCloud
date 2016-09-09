//
//  HITWeightedWordCloud.m
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

#ifndef EXTENSION_TARGET
    @import UIKit;
#else
    @import WatchKit;
#endif

#import "HITWeightedWordCloud.h"

#define kMaxPositioningRetries 100

@interface HITWeightedWordCloud ()

@property (nonatomic, strong) NSMutableArray *wordFrames;

@end

@implementation HITWeightedWordCloud

- (instancetype)init
{
    self = super.init;
    
    if (self) {
        self.size = CGSizeZero;
        self.backgroundColor = UIColor.clearColor;
        self.minFontSize = self.smallSystemFontSize * 0.6;
        self.maxFontSize = self.systemFontSize * 1.4;
    }
    
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    self = super.init;
    
    if (self) {
        self.size = size;
        self.backgroundColor = UIColor.clearColor;
        self.minFontSize = self.smallSystemFontSize * 0.6;
        self.maxFontSize = self.systemFontSize * 1.4;
    }
    
    return self;
}

#pragma mark - Image generation

- (CGSize)minimumSizeWithWords:(NSDictionary *)wordDictionary
{
    NSAssert(self.origin != HITWeightedWordCloudOriginRandom, @"HITWeightedWordCloudOriginRandom is not supported for size calculation");
    
    CGRect minimumRect = CGRectZero;
    self.wordFrames = NSMutableArray.new;
    
    // Sort words by weight. This prioritizes the rendering of the more important words.
    NSArray *weighedWords = [self sortedKeysInDictionary:wordDictionary];
    
    for (NSString *word in weighedWords) {
        CGRect wordFrame = [self frameForWord:word inDictionary:wordDictionary];
        
        if (!CGRectIsEmpty(wordFrame)) {
            [self.wordFrames addObject:[NSValue valueWithCGRect:wordFrame]];
            minimumRect = CGRectUnion(minimumRect, wordFrame);
        }
    }
    
    return CGSizeMake(ceil(minimumRect.size.width), ceil(minimumRect.size.height));
}

- (UIImage *)imageWithWords:(NSDictionary *)wordDictionary
{
    self.wordFrames = NSMutableArray.new;
    
    // Sort words by weight. This prioritizes the rendering of the more important words.
    NSArray *weighedWords = [self sortedKeysInDictionary:wordDictionary];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), NO, self.scale);
    
    // Background fill
    if (CGColorGetAlpha(self.backgroundColor.CGColor) > 0) {
        [self.backgroundColor setFill];
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    }
    
    // Draw each word
    for (NSString *word in weighedWords) {
        CGRect wordFrame = [self frameForWord:word inDictionary:wordDictionary];
        
        // If the word fit, save its frame for future intersection testing and render the word.
        if (!CGRectIsEmpty(wordFrame)) {
            [self.wordFrames addObject:[NSValue valueWithCGRect:wordFrame]];
            [word drawInRect:wordFrame withAttributes:[self fontAttribuesForWord:word inDictionary:wordDictionary]];
        }
    }
    
    // Create a UIImage from the graphics context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (CGRect)frameForWord:(NSString *)word inDictionary:(NSDictionary *)wordDictionary
{
    CGRect wordFrame;
    
    NSDictionary *fontAttributes = [self fontAttribuesForWord:word inDictionary:wordDictionary];
    
    // Try to position the word so that it does not intersect other words. Random positions are used for kMaxPositioningRetries. After kMaxPositioningRetries is reached, we give up and drop this word as it probably doesn't fit.
    NSUInteger retries = 0;
    
    do {
        switch (self.origin) {
            case HITWeightedWordCloudOriginRandom:
                wordFrame = [self randomFrameForText:word withAttributes:fontAttributes inContext:UIGraphicsGetCurrentContext()];
                break;
            case HITWeightedWordCloudOriginTopLeft:
                wordFrame = [self topLeftFrameForText:word withAttributes:fontAttributes];
                break;
        }
        retries++;
    } while ([self frameIntersectsOtherWords:wordFrame] && retries < kMaxPositioningRetries);
    
    // If the word fit, return the frame.
    if (retries < kMaxPositioningRetries) {
        return wordFrame;
    } else {
        return CGRectNull;
    }
}

- (NSDictionary *)fontAttribuesForWord:(NSString *)word inDictionary:(NSDictionary *)wordDictionary
{
    // Calculate minimum and maximum weight for font size mapping.
    CGFloat minWeight = [[wordDictionary.allValues valueForKeyPath:@"@min.self"] floatValue], maxWeight = [[wordDictionary.allValues valueForKeyPath:@"@max.self"] floatValue];
    
    // Map weight to font size
    int weightRange = maxWeight - minWeight;
    int fontSizeRange = self.maxFontSize - self.minFontSize;
    CGFloat weighedFontSize = ([wordDictionary[word] floatValue] - maxWeight) * fontSizeRange / weightRange + self.maxFontSize;
    
    // Font size and color
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:weighedFontSize], NSForegroundColorAttributeName: self.textColor};
    
    return attributes;
}

#pragma mark - Positioning

/**
 *  Creates a random frame matching certain parameters.
 *
 *  @param text       The text to create a frame for.
 *  @param attributes Text attributes like font size etc.
 *  @param context    A CGContextRef for canvas size.
 *
 *  @return A random frame for the given text.
 */
- (CGRect)randomFrameForText:(NSString *)text withAttributes:(NSDictionary *)attributes inContext:(CGContextRef)context
{
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGFloat maxWidth = CGBitmapContextGetWidth(context) / self.scale - textSize.width;
    CGFloat maxHeight = CGBitmapContextGetHeight(context) / self.scale - textSize.height;
    
    CGRect randomFrame = CGRectMake(random() % (NSInteger)maxWidth, random() % (NSInteger)maxHeight, textSize.width, textSize.height);
    
    return randomFrame;
}

/**
 *  Creates a top-left frame for the supplied text.
 *
 *  @param text       The text to create a frame for.
 *  @param attributes Text attributes like font size etc.
 *
 *  @return The top left frame for the supplied text.
 */
- (CGRect)topLeftFrameForText:(NSString *)text withAttributes:(NSDictionary *)attributes
{
    CGRect lastFrame = [self.wordFrames.lastObject CGRectValue];
    
    CGSize textSize = [text sizeWithAttributes:attributes];
    
    CGRect topLeftFrame = CGRectMake(0, CGRectGetMaxY(lastFrame), textSize.width, textSize.height);
    
    lastFrame = CGRectMake(CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame) + 2.0, CGRectGetWidth(lastFrame), CGRectGetHeight(lastFrame));
    
    return topLeftFrame;
}

/**
 *  Checks if a frame intersects any other word rect in self.wordFrames.
 *
 *  @param rect The frame to be tested.
 *
 *  @return Whether the input frame interescts any rect in self.wordFrames.
 */
- (BOOL)frameIntersectsOtherWords:(CGRect)rect
{
    for (NSValue *frameValue in self.wordFrames) {
        CGRect wordFrame = frameValue.CGRectValue;
        
        if (CGRectIntersectsRect(rect, wordFrame)) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Helpers

- (NSArray *)sortedKeysInDictionary:(NSDictionary *)wordDictionary
{
    return [wordDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
}

- (CGFloat)systemFontSize
{
    #ifndef EXTENSION_TARGET
        return UIFont.systemFontSize;
    #else
        return 17;
    #endif
}

- (CGFloat)smallSystemFontSize
{
    #ifndef EXTENSION_TARGET
        return UIFont.smallSystemFontSize;
    #else
        return 12;
    #endif
}

@end
