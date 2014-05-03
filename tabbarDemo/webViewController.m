//
//  SecondViewController.m
//  tabbarDemo
//
//  Created by WebosterBob on 4/24/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()

@end

@implementation webViewController
@synthesize goWebView = _goWebView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goWeb:(id)sender
{
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [_goWebView loadRequest:request];
    
}
@end
