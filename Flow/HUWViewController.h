//
//  HUWViewController.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUWFlow.h"

@interface HUWViewController : UIViewController<UIScrollViewDelegate, HUWFlowDelegate>

@property (weak, nonatomic) IBOutlet HUWFlow *scrollView;

@end
