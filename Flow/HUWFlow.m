//
//  HUWFlow.m
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HUWFlow.h"
#import "HUWImageHelpers.h"

@interface HUWFlow ()

-(void)__scrollViewDidScroll;
-(void)__init;

@end

@implementation HUWFlow

-(void)__init {
    images = [NSMutableArray array];
    loaderQueue = [[NSOperationQueue alloc] init];
    loaderQueue.maxConcurrentOperationCount = 1;
    self.delegate = nil;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    [self addGestureRecognizer:tap];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __init];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __init];
    }
    return self;
}
                                   
-(void)didTapView:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:self];

    for (int i=0; i<[images count]; i++) {
        UIView *view = [images objectAtIndex:i];
        
        if (CGRectContainsPoint(view.frame, point)) {
            [self setSelectedView:view];
            break;
        }
    }
}

-(void)setSelectedIndex:(int)index {
    UIView *view = [images objectAtIndex:index];
    [self setSelectedView:view];
}

-(void)setSelectedView:(UIView*)view {
    if (selectedView.layer.sublayers.count == 2) {
        [[selectedView.layer.sublayers objectAtIndex:1] removeFromSuperlayer];
    }
    
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = CGRectInset(view.bounds, 8, 8);
    sublayer.shadowPath = CGPathCreateWithRect(sublayer.frame, 0);
    sublayer.shadowColor = [UIColor blueColor].CGColor;
    sublayer.shadowRadius = 4.0f;
    sublayer.borderWidth = 1.0f;
    sublayer.borderColor = [UIColor blueColor].CGColor;
    [view.layer addSublayer:sublayer];
    
    selectedView = view;
    
    CGRect frame = CGRectMake(view.center.x - self.bounds.size.width / 2, 0, self.bounds.size.width, self.bounds.size.height);
    [self scrollRectToVisible:frame animated:YES];
}

-(void)setFrame:(CGRect)frame {
    CGFloat ratio = frame.size.width / self.frame.size.width;
    [super setFrame:frame];
    
    CGRect contentRect = self.bounds;
    CGFloat size = self.bounds.size.width / 2;
    
    for (int i=0; i<[images count]; i++) {
        UIImageView *imageView = [images objectAtIndex:i];
        
        CGRect frame = CGRectMake(size / 2 + i * size, self.bounds.size.height / 2 - size / 2, size, size);
        imageView.frame = frame;
        
        if (imageView.layer.sublayers.count) {
            [[imageView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
        }
        
        UIImage *reflection = [HUWImageHelpers reflectedImage:imageView withHeight:50];
        CALayer *sublayer = [CALayer layer];
        sublayer.contents = (id)reflection.CGImage;
        sublayer.opacity = 0.3;
        sublayer.frame = CGRectMake(0, frame.size.height + 20, frame.size.width, reflection.size.height);
        [imageView.layer addSublayer:sublayer];
        
        contentRect = CGRectUnion(contentRect, frame);
    }
    
    contentRect.size.width += size;
    self.contentSize = contentRect.size;
    
    CGPoint offset = self.contentOffset;
    offset.x = offset.x * ratio;
    self.contentOffset = offset;
}

-(void)addImageWithUrl:(NSURL *)url {
    [self addImageWithLoader:^UIImage *(NSError *__autoreleasing *error) {
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }];
}

-(void)addImage:(UIImage *)image {
    [self addImageWithLoader:^UIImage *(NSError *__autoreleasing *error) {
        return image;
    }];
}

-(void)addImageWithLoader:(ImageLoaderBlock_t)image {
    UIImageView *imageView = [[UIImageView alloc] init];
    [images addObject:imageView];
    int idx = [images indexOfObject:imageView];
    
    __block HUWFlow *s = self;
    
    [loaderQueue addOperationWithBlock:^{
        NSError *error = nil;
        imageView.image = image(&error);
        
        
        CGFloat size = self.bounds.size.width / 2;
        CGRect frame = CGRectMake(size / 2 + idx * size, self.bounds.size.height / 2 - size / 2, size, size);
        imageView.frame = frame;
        
        UIImage *reflection = [HUWImageHelpers reflectedImage:imageView withHeight:50];
        
        CALayer *sublayer = [CALayer layer];
        sublayer.contents = (id)reflection.CGImage;
        sublayer.opacity = 0.3;
        sublayer.frame = CGRectMake(0, frame.size.height + 20, frame.size.width, reflection.size.height);
        [imageView.layer addSublayer:sublayer];
        
        frame.size.width += size / 2.0f;
        CGSize contentSize = CGRectUnion(self.bounds, frame).size;
        self.contentSize = contentSize;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [s addSubview:imageView];
            [s __scrollViewDidScroll];
        });
    }];
}

-(void)__scrollViewDidScroll {
    CGPoint offset = self.contentOffset;
    
    for (UIView *view in images) {
        CGFloat viewWidth = self.bounds.size.width;
        CGFloat distance = view.center.x - (offset.x + viewWidth / 2);
        CGFloat aDistance = fabsf(distance);
        if (aDistance < self.bounds.size.width + view.frame.size.width) {
            CGFloat angle = -60.0f * (distance / (self.bounds.size.width/2));
            
            CGFloat zt = 0.0f;
            if (aDistance < view.frame.size.width / 2) {
                zt = aDistance / (view.frame.size.width / 2);
                zt = (1 + sinf((zt+0.5f) * M_PI)) * 25.0f;
            }
            
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500;
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, 0, zt);
            view.layer.transform = CATransform3DRotate(
                                                       rotationAndPerspectiveTransform,
                                                       angle * M_PI / 180.0f,
                                                       0.0f, 1.0f, 0.0f);
        }
    }
}

-(void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    delegateWrapper = [[HUWFlowDelegateWrapper alloc] init];
    delegateWrapper.wrappedDelegate = delegate;
    delegateWrapper.internalDelegate = self;
    [super setDelegate:delegateWrapper];
}

-(id<UIScrollViewDelegate>)delegate {
    return [super delegate];
}

@end
