//
//  HUWFlowDelegateWrapper.m
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import "HUWFlowDelegateWrapper.h"

@implementation HUWFlowDelegateWrapper

@synthesize wrappedDelegate = __wrappedDelegate, internalDelegate = __internalDelegate;

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.wrappedDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.wrappedDelegate];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.internalDelegate performSelector:@selector(__scrollViewDidScroll) withObject:scrollView];
    if ([self.wrappedDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.wrappedDelegate scrollViewDidScroll:scrollView];
    }
}

@end
