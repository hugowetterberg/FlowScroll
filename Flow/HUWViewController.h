//
//  HUWViewController.h
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Good Old AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUWFlow.h"

@interface HUWViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet HUWFlow *scrollView;

@end
