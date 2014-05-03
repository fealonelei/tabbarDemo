//
//  imageViewController.h
//  tabbarDemo
//
//  Created by WebosterBob on 4/24/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)selectPicFromAlbum:(id)sender;

- (IBAction)selectPicFromCamera:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *showPic;

@end
