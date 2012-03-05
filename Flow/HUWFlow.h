//
//  HUWFlow.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUWFlowDelegateWrapper.h"
#import "HUWFlowDelegate.h"

typedef UIImage* (^ImageLoaderBlock_t)(NSError** error);

@interface HUWFlow : UIScrollView {
@private
    HUWFlowDelegateWrapper *delegateWrapper;
    NSMutableArray *images;
    NSOperationQueue *loaderQueue;
    __weak UIView *selectedView;
}

@property (weak, nonatomic) id<HUWFlowDelegate> flowDelegate;

-(void)addImageWithUrl:(NSURL *)url;
-(void)addImage:(UIImage *)image;
-(void)addImageWithLoader:(ImageLoaderBlock_t)image;
-(void)setSelectedIndex:(int)index;
-(void)setSelectedIndex:(int)index animated:(BOOL)animated;

@end
