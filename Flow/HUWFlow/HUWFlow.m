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
-(CGRect)__frameForImage:(UIImage*)image atIndex:(int)idx;
-(void)setSelectedView:(UIView*)view animated:(BOOL)animated;

@end

@implementation HUWFlow

@synthesize flowDelegate = __flowDelegate;

-(void)__init {
    images = [NSMutableArray array];
    loaderQueue = [[NSOperationQueue alloc] init];
    self.maxConcurrentImageLoaders = 2;
    self.delegate = nil;
    latestAdded = 0;
    
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

-(NSInteger)maxConcurrentImageLoaders {
    return loaderQueue.maxConcurrentOperationCount;
}

-(void)setMaxConcurrentImageLoaders:(NSInteger)maxConcurrentImageLoaders {
    loaderQueue.maxConcurrentOperationCount = maxConcurrentImageLoaders;
}

                                   
-(void)didTapView:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:self];

    for (int i=0; i<[images count]; i++) {
        UIView *view = [images objectAtIndex:i];
        
        if (CGRectContainsPoint(view.frame, point)) {
            [self setSelectedView:view animated:YES];
            [self.flowDelegate flowDidSelectItem:i];
            break;
        }
    }
}

-(void)setSelectedIndex:(int)index {
    [self setSelectedIndex:index animated:YES];
}

-(void)setSelectedIndex:(int)index animated:(BOOL)animated {
    UIView *view = [images objectAtIndex:index];
    [self setSelectedView:view animated:animated];
}

-(void)setSelectedView:(UIView*)view animated:(BOOL)animated {
    selectedView = view;
    
    CGRect frame = CGRectMake(view.center.x - self.bounds.size.width / 2, 0, self.bounds.size.width, self.bounds.size.height);
    [self scrollRectToVisible:frame animated:animated];
}

-(void)setFrame:(CGRect)frame {
    CGFloat ratio = frame.size.width / self.frame.size.width;
    [super setFrame:frame];
    
    CGRect contentRect = self.bounds;
    CGFloat size = self.bounds.size.width / 2;
    
    for (int i=0; i<[images count]; i++) {
        UIImageView *imageView = [images objectAtIndex:i];
        
        if (imageView.image) {
            CGRect imageRect = imageView.frame = [self __frameForImage:imageView.image atIndex:i];
            
            if (imageView.layer.sublayers.count) {
                CALayer *sublayer = [imageView.layer.sublayers objectAtIndex:0];
                UIImage *reflection = [HUWImageHelpers reflectedImage:imageView withHeight:50];
                sublayer.contents = (id)reflection.CGImage;
                
                CGRect reflFrame = sublayer.frame;
                reflFrame.origin.y = imageRect.size.height + 20;
                reflFrame.size.width = imageRect.size.width;
                sublayer.frame = reflFrame;
            }
        }
        
        contentRect = CGRectUnion(contentRect, imageView.frame);
    }
    
    contentRect.size.width += size;
    self.contentSize = contentRect.size;
    
    CGPoint offset = self.contentOffset;
    offset.x = offset.x * ratio;
    self.contentOffset = offset;
    [self __scrollViewDidScroll];
}

-(void)addImageWithUrl:(NSURL *)url {
    [self addImageWithLoader:^UIImage *(NSError *__autoreleasing *error) {
        UIImage *image = nil;
        if (url) {
            NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
            if (!*error) {
                image = [UIImage imageWithData:data];
                if (!image) {
                    *error = [NSError errorWithDomain:@"nu.wetterberg.Flow" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Could not read image", NSLocalizedDescriptionKey, nil]];
                }
            }
        }
        else {
            *error = [NSError errorWithDomain:@"nu.wetterberg.Flow" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Empty or malformed url for image", NSLocalizedDescriptionKey, nil]];
        }
        
        return image;
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
    
    CGFloat width = self.bounds.size.width / 2;
    __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect sframe = spinner.frame;
    sframe.origin.x = width * (idx+1) - sframe.size.width / 2;
    sframe.origin.y = self.bounds.size.height / 2 - sframe.size.height / 2;
    spinner.frame = sframe;
    [spinner startAnimating];
    [self addSubview:spinner];
    
    __block HUWFlow *s = self;
    __block int *latest = &latestAdded;
    
    [loaderQueue addOperationWithBlock:^{
        NSError *error = nil;
        imageView.image = image(&error);
        if (error) {
            imageView.image = [s.flowDelegate flowFailedToLoadImage:idx withError:error];
        }
        
        CGRect frame = [s __frameForImage:imageView.image atIndex:idx];
        imageView.frame = frame;
        
        UIImage *reflection = [HUWImageHelpers reflectedImage:imageView withHeight:50];
        
        CALayer *sublayer = [CALayer layer];
        sublayer.contents = (id)reflection.CGImage;
        sublayer.opacity = 0.3;
        sublayer.frame = CGRectMake(0, frame.size.height + 20, frame.size.width, reflection.size.height);
        [imageView.layer addSublayer:sublayer];
        
        frame.size.width += frame.size.width / 2.0f;
        if (idx >= *latest) {
            CGSize contentSize = CGRectUnion(s.bounds, frame).size;
            s.contentSize = contentSize;
            *latest = idx;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner removeFromSuperview];
            [s addSubview:imageView];
            [s __scrollViewDidScroll];
        });
    }];
}

-(CGRect)__frameForImage:(UIImage*)image atIndex:(int)idx {
    CGSize constraint = CGSizeMake(self.bounds.size.width / 2, self.bounds.size.height * 0.6283185307);
    CGSize ratio = CGSizeMake(image.size.width / constraint.width, image.size.height / constraint.height);
    CGFloat constraining = MAX(ratio.width, ratio.height);
    CGSize scaled = CGSizeMake(image.size.width / constraining, image.size.height / constraining);
    
    CGRect rect = CGRectMake(constraint.width * idx + constraint.width / 2, 
                             self.bounds.size.height / 2 - scaled.height / 2,
                             scaled.width, scaled.height);
    
    return CGRectIntegral(rect);
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
