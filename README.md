# WeightedWordCloud

[![Version](https://img.shields.io/cocoapods/v/WeightedWordCloud.svg?style=flat)](http://cocoapods.org/pods/WeightedWordCloud)
[![License](https://img.shields.io/cocoapods/l/WeightedWordCloud.svg?style=flat)](http://cocoapods.org/pods/WeightedWordCloud)
[![Platform](https://img.shields.io/cocoapods/p/WeightedWordCloud.svg?style=flat)](http://cocoapods.org/pods/WeightedWordCloud)

Works with any Objective-C project, including app extensions like today widgets and Apple Watch (WatchKit) apps.

![alt text](https://raw.githubusercontent.com/maciekish/WeightedWordCloud/master/Screenshot.png "Logo Title Text 1")

## Example usage with WatchKit

Import the header
```objectivec
#import <WeightedWordCloud/HITWeightedWordCloud.h>
```

Create and configure a HITWeightedWordCloud object. You can do this in `(void)awakeWithContext:(id)context`
```objectivec
self.wordCloud = [HITWeightedWordCloud.alloc initWithSize:CGSizeMake(CGRectGetWidth(self.contentFrame), CGRectGetHeight(self.contentFrame)];
self.wordCloud.textColor = UIColor.whiteColor;
self.wordCloud.scale = WKInterfaceDevice.currentDevice.screenScale;
```

Set data and render a word cloud. The dictionary key is your word and the value is the weight. The weight controls the font size of the words in the rendered cloud.
```objectivec
NSDictionary *wordsDictionary = @{@"Very important": @500,
								  @"Still important": @400,
                                  @"Less important": @100,
                                  @"Not important at all": @0};
[self.imageView setImage:[self.wordCloud imageWithWords:wordsDictionary]];
```

See the header file for more options.

## Requirements

* Xcode 6.3.1
* ARC

## Installation

WeightedWordCloud is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WeightedWordCloud', '0.1.0'
```

## Author

Maciej Swic, maciej@swic.name

## License

WeightedWordCloud is available under the MIT license. See the LICENSE file for more info.

