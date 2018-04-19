//
//  ViewController.m
//  CombineBarANDWave
//
//  Created by Maple on 19/04/2018.
//  Copyright © 2018 Maple. All rights reserved.
//

#import "ViewController.h"
#import "MLBarWaveView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MLBarWaveView *waveView = [[MLBarWaveView alloc] initWithFrame:CGRectMake(10, 50, 300, 300)];
    waveView.yAxisDataSource = @[@"10", @"15", @"30",@"1", @"5", @"13",@"19", @"28", @"24",@"10", @"15", @"30",@"20", @"18", @"30",@"10", @"15", @"30",@"16", @"15", @"30",@"10", @"28"];
    waveView.xAxisDataSouce = @[@"1", @"2", @"3", @"4", @"5", @"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    [self.view addSubview:waveView];
    
}


 

@end
