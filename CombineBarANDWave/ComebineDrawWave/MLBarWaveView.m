//
//  MLBarWaveView.m
//  CombineBarANDWave
//
//  Created by Maple on 19/04/2018.
//  Copyright © 2018 Maple. All rights reserved.
//

#import "MLBarWaveView.h"
#import "ZFChart.h"

@interface MLBarWaveView ()<ZFGenericChartDataSource, ZFBarChartDelegate>

@property (nonatomic, strong) ZFBarChart * chartView;

@property (nonatomic, assign) CGFloat height;

@end
@implementation MLBarWaveView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chartView = [[ZFBarChart alloc] initWithFrame:frame];
        _chartView.dataSource = self;
        _chartView.delegate = self;
        
        _chartView.topicLabel.text = @"xx小学各年级人数";
        
        _chartView.isAnimated = NO;
        _chartView.isShadowForValueLabel = NO;
        _chartView.isResetAxisLineMaxValue = YES;
        _chartView.isShowXLineSeparate = NO;
        _chartView.isShowYLineSeparate = NO;
        _chartView.xAxisColor = [UIColor blackColor];
        _chartView.yAxisColor = [UIColor blackColor];;
        _chartView.axisLineNameColor = [UIColor blackColor];
        _chartView.axisLineValueColor = [UIColor blackColor];
        _chartView.backgroundColor = [UIColor whiteColor];// 图表背景色
        _chartView.isShowAxisArrows = NO;
        _chartView.separateLineStyle = kLineStyleDashLine;
        _chartView.isMultipleColorInSingleBarChart= YES;

        [self addSubview:_chartView];
        [_chartView strokePath];
    }
    return self;
}

- (void)setYAxisDataSource:(NSArray *)yAxisDataSource {
    _yAxisDataSource = yAxisDataSource;
    [_chartView strokePath];
}

- (void)setXAxisDataSouce:(NSArray *)xAxisDataSouce {
    _xAxisDataSouce = xAxisDataSouce;
    [_chartView strokePath];
}

#pragma mark - ZFGenericChartDataSource
- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return self.yAxisDataSource;
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return self.xAxisDataSouce;
    
}


// 柱状图颜色
- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[[UIColor blueColor]];
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return 30;
}

- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return 5;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 10;
}

@end
