//
//  FirstViewController.m
//  tabbarDemo
//
//  Created by WebosterBob on 4/24/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import "textViewController.h"

@interface textViewController ()
@end

@implementation textViewController
@synthesize segmentController = _segmentController;
@synthesize myDatePicker      = _myDatePicker;
@synthesize myPickView        = _myPickView;

@synthesize pickerProvinceData = _pickerProvinceData;
@synthesize pickerCitiesData   = _pickerCitiesData;
@synthesize pickerDistrictData = _pickerDistrictData;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.scollView.contentSize = CGSizeMake(320, 600);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchDown:(id)sender
{
    if (_segmentController.selectedSegmentIndex == 0)
    {
        _myDatePicker.hidden = false;
        _myPickView.hidden = true;
    }
    else if (_segmentController.selectedSegmentIndex == 1)
    {
        _myDatePicker.hidden = true;
        _myPickView.hidden = false;
        
        _myPickView.delegate = self;
        _myPickView.dataSource = self;
        
        //获取所有数据
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"provinces_cities" ofType:@"plist"];
        self.pickerData = [[NSDictionary alloc] initWithContentsOfFile:dataPath];
        
        //省数据
        NSArray *components = [self.pickerData allKeys];
        
        NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
        for (int i = 0; i < [sortedArray count]; i++)
        {
            NSString *index = [sortedArray objectAtIndex:i];
            NSArray *tmp    = [[self.pickerData objectForKey: index] allKeys];
            [provinceTmp addObject: [tmp objectAtIndex:0]];
        }
        _pickerProvinceData = [[NSArray alloc] initWithArray: provinceTmp];
        
        NSString *index = [sortedArray objectAtIndex:0];
        NSString *selected = [_pickerProvinceData objectAtIndex:0];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [[self.pickerData objectForKey:index]objectForKey:selected]];
        
        NSArray *cityArray = [dic allKeys];
        NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [cityArray objectAtIndex:0]]];
        _pickerCitiesData = [[NSArray alloc] initWithArray: [cityDic allKeys]];
        
        
        NSString *selectedCity = [_pickerCitiesData objectAtIndex: 0];
        _pickerDistrictData = [[NSArray alloc] initWithArray: [cityDic objectForKey: selectedCity]];
        
        //默认显示第一个省得市
        selectedProvince = [_pickerProvinceData objectAtIndex:0];
        //_pickerCitiesData = [self.pickerData objectForKey:[_pickerProvinceData objectAtIndex:0]];
        //[self showSelected];
    }
}


//UIPickerViewDataSource
//选择器中拨轮的数目
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

//UIPickerViewDataSource
//选择器中某个拨轮的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)           //省
    {
        return [_pickerProvinceData count];
    }
    else if(component == 1)      //市
    {
        return [_pickerCitiesData count];
    }
    else
    {
        return [_pickerDistrictData count];
    }
}

//UIPickerViewDelegate
//选择器中某个拨轮的某行显示的数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [_pickerProvinceData objectAtIndex: row];
    }
    else if (component == 1)
    {
        return [_pickerCitiesData objectAtIndex: row];
    }
    else
    {
        return [_pickerDistrictData objectAtIndex: row];
    }
}

//UIPickerViewDelegate
//选中选择器中某个拨轮的某行时触发
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)   //选中省时显示对应的市
    {
        selectedProvince = [_pickerProvinceData objectAtIndex: row];
        NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [self.pickerData objectForKey: [NSString stringWithFormat:@"%ld", (long)row]]];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
        NSArray *cityArray = [dic allKeys];
        NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;//递减
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;//上升
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i=0; i<[sortedArray count]; i++) {
            NSString *index = [sortedArray objectAtIndex:i];
            NSArray *temp = [[dic objectForKey: index] allKeys];
            [array addObject: [temp objectAtIndex:0]];
        }
        
        _pickerCitiesData = [[NSArray alloc] initWithArray: array];

        NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
        _pickerDistrictData = [[NSArray alloc] initWithArray: [cityDic objectForKey: [_pickerCitiesData objectAtIndex: 0]]];
        [_myPickView selectRow: 0 inComponent: 1 animated: YES];
        [_myPickView selectRow: 0 inComponent: 2 animated: YES];
        
        [self.myPickView reloadComponent: 1];
        [self.myPickView reloadComponent: 2];
    }
    
    else if (component == 1)
    {
        NSString *provinceIndex = [NSString stringWithFormat: @"%lu", (unsigned long)[_pickerProvinceData indexOfObject: selectedProvince]];
        NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [_pickerData objectForKey: provinceIndex]];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
        NSArray *dicKeyArray = [dic allKeys];
        NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
        NSArray *cityKeyArray = [cityDic allKeys];
        
        _pickerDistrictData = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
        [self.myPickView selectRow: 0 inComponent: 2 animated: YES];
        [self.myPickView reloadComponent: 2];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 80;
    }
    else if (component == 1)
    {
        return 100;
    }
    else
    
    {
        return 115;
    }
}



- (IBAction)clickToChangeLabel:(id)sender
{
    if(_segmentController.selectedSegmentIndex == 0)
    {
        NSDate *theDate = _myDatePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        self.contentLabel.text = [dateFormatter stringFromDate:theDate];
    }
    else if(_segmentController.selectedSegmentIndex == 1)
    {
        NSInteger provinceIndex = [self.myPickView selectedRowInComponent: 0];
        NSInteger cityIndex     = [self.myPickView selectedRowInComponent: 1];
        NSInteger districtIndex = [self.myPickView selectedRowInComponent: 2];
        
        NSString *provinceStr = [_pickerProvinceData objectAtIndex: provinceIndex];
        NSString *cityStr     = [_pickerCitiesData objectAtIndex: cityIndex];
        NSString *districtStr = [_pickerDistrictData objectAtIndex:districtIndex];
        
        if ([provinceStr isEqualToString: cityStr] && [cityStr isEqualToString: districtStr]) {
            cityStr = @"";
            districtStr = @"";
        }
        else if ([cityStr isEqualToString: districtStr]) {
            districtStr = @"";
        }
        
        NSString *showMsg = [NSString stringWithFormat: @"%@ %@ %@.", provinceStr, cityStr, districtStr];
    
        self.contentLabel.text = showMsg;
    }
    
    
}
@end


































//@property 夏青
//    夏青.isSB = true;
//    夏青.isSB.isEditable = false;
//    if(夏青.essential == 250)
//    {
//        夏青.IQ.Locked = forever(2);
//    }
//    else
//    {
//        夏青.IQ.Locked = forever(-64436421684.316845313115468151);
//        throw exception("夏青禽兽");
//    }
//@end
