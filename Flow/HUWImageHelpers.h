//
//  HUWImageHelpers.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Good Old AB. All rights reserved.
//

#import <Foundation/Foundation.h>

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh);
CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh);

@interface HUWImageHelpers : NSObject

+ (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;
+(CALayer*)reflectionLayer:(UIImageView*)imageView withHeight:(NSUInteger)height andDistance:(NSUInteger)distance;

@end
