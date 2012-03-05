//
//  HUWViewController.m
//  Flow
//
//  Created by Hugo Wetterberg on 2012-03-02.
//  Copyright (c) 2012 Hugo Wetterberg. All rights reserved.
//

#import "HUWViewController.h"

@interface HUWViewController ()

@end

@implementation HUWViewController

@synthesize scrollView = __scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"images" ofType:@"json"]] options:0 error:nil];
    for (NSDictionary *info in json) {
        NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:[info objectForKey:@"name"] withExtension:@"jpg"];
        [self.scrollView addImageWithUrl:imageUrl];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
