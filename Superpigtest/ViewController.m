//
//  ViewController.m
//  Superpigtest
//
//  Created by Hsu Cloud on 2012/10/25.
//  Copyright (c) 2012年 Orz. All rights reserved.
//

#import "CBiOSStoreManager.h"
#import "ViewController.h"

#define ProductID_IAP_1 @"id_zuanshi_1_"
#define ProductID_IAP_2 @"id_zuanshi_1_"
#define ProductID_IAP_3 @"id_zuanshi_1_"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //m_test = [[CloudTest alloc] init];
    [[CBiOSStoreManager sharedInstance] initialStore];
    [[CBiOSStoreManager sharedInstance] buy:ProductID_IAP_1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[CBiOSStoreManager sharedInstance] releaseStore];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
