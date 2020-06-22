//
//  ViewController.m
//  UZBroadcastDemo
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "MainViewController.h"
#import "UZBroadcastPreview.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     [self.view addSubview:[[UZBroadcastPreview alloc] initWithFrame:self.view.bounds]];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
