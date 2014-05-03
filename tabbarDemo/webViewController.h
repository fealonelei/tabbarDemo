//
//  SecondViewController.h
//  tabbarDemo
//
//  Created by WebosterBob on 4/24/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController <UIWebViewDelegate>

- (IBAction)goWeb:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *goWebView;

@end
