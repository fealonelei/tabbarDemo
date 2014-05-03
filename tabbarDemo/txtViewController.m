//
//  txtViewController.m
//  tabbarDemo
//
//  Created by WebosterBob on 4/29/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import "txtViewController.h"

@interface txtViewController ()

@end

@implementation txtViewController
@synthesize leftSwipeGestureRecognizer = _leftSwipeGestureRecognizer;
@synthesize rightSwipeGestureRecognizer = _rightSwipeGestureRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
//        CGPoint labelPosition = CGPointMake(self.swipeLabel.frame.origin.x - 100.0, self.swipeLabel.frame.origin.y);
//        self.swipeLabel.frame = CGRectMake( labelPosition.x , labelPosition.y , self.swipeLabel.frame.size.width, self.swipeLabel.frame.size.height);
//        self.swipeLabel.text = @"尼玛的, 你在往左边跑啊....";
        [self dismissViewControllerAnimated:YES completion:^{}];
        
    }

//    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
//    {
//        CGPoint labelPosition = CGPointMake(self.swipeLabel.frame.origin.x + 100.0, self.swipeLabel.frame.origin.y);
//        self.swipeLabel.frame = CGRectMake( labelPosition.x , labelPosition.y , self.swipeLabel.frame.size.width, self.swipeLabel.frame.size.height);
//        self.swipeLabel.text = @"尼玛的, 你在往右边跑啊....";
//    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.leftSwipeGestureRecognizer.direction  = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

    [self.view addGestureRecognizer:_leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:_rightSwipeGestureRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
