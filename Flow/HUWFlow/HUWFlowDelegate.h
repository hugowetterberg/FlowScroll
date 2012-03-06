//
//  HUWFlowDelegate.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-05.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HUWFlowDelegate <NSObject>

-(void)flowDidSelectItem:(int)index;
-(UIImage*)flowFailedToLoadImage:(int)index;

@end
