//
//  HUWFlowDelegateWrapper.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUWFlowDelegateWrapper : NSObject<UIScrollViewDelegate>

@property (weak, nonatomic) id<UIScrollViewDelegate> wrappedDelegate;
@property (weak, nonatomic) id internalDelegate;

@end
