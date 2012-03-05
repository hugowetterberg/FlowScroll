//
//  HUWFlow.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUWFlowDelegateWrapper.h"

@interface HUWFlow : UIScrollView {
@private
    HUWFlowDelegateWrapper *delegateWrapper;
    NSMutableArray *images;
    NSOperationQueue *loaderQueue;
    __weak UIView *selectedView;
}

-(void)addImageWithUrl:(NSURL *)url;
-(void)setSelectedIndex:(int)index;
-(void)setSelectedView:(UIView*)view;

@end
