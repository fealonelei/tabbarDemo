//
//  FirstViewController.h
//  tabbarDemo
//
//  Created by WebosterBob on 4/24/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textViewController : UIViewController <UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIPickerView *myPickView;
    NSArray *pickerData;
    
    NSString *selectedProvince;
}

- (IBAction)clickToChangeLabel:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scollView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *myPickView;

@property (strong, nonatomic) NSDictionary *pickerData;
@property (strong, nonatomic) NSArray *pickerProvinceData;
@property (strong, nonatomic) NSArray *pickerCitiesData;
@property (strong, nonatomic) NSArray *pickerDistrictData;


- (IBAction)touchDown:(id)sender;

@end
