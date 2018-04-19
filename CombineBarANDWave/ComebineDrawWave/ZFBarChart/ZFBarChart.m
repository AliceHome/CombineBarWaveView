//
//  ZFBarChart.m
//  ZFChartView
//
//  Created by apple on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZFBarChart.h"
#import "ZFWaveChart.h"

#import "ZFGenericAxis.h"
#import "NSString+Zirkfied.h"
#import "ZFMethod.h"

@interface ZFBarChart()<ZFGenericAxisDelegate,ZFGenericAxisDelegate>

/** 通用坐标轴图表 */
@property (nonatomic, strong) ZFGenericAxis * genericAxis;
/** 存储柱状条的数组 */
@property (nonatomic, strong) NSMutableArray * barArray;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray * colorArray;
/** 存储popoverLaber数组 */
@property (nonatomic, strong) NSMutableArray * popoverLaberArray;
/** 存储value文本颜色的数组 */
@property (nonatomic, strong) NSMutableArray * valueTextColorArray;
/** 存储bar渐变色的数组 */
@property (nonatomic, strong) NSMutableArray * gradientColorArray;
/** bar宽度 */
@property (nonatomic, assign) CGFloat barWidth;
/** bar与bar之间的间距 */
@property (nonatomic, assign) CGFloat barPadding;

//波浪线
/** 波浪path */

/** 波浪path */
@property (nonatomic, strong) ZFWave * wave;
/** 存储path渐变色 */
@property (nonatomic, strong) ZFGradientAttribute * gradientAttribute;
/** 存储点的位置的数组 */
@property (nonatomic, strong) NSMutableArray * valuePointArray;
 
@end

@implementation ZFBarChart

/**
 *  初始化变量
 */
- (void)commonInit{
    [super commonInit];

    _overMaxValueBarColor = ZFRed;
    _isShadow = NO;
    _barWidth = ZFAxisLineItemWidth;
    _barPadding = ZFAxisLinePaddingForBarLength;
    _valueTextColor = ZFBlack;
    
    
    _pathColor = ZFSkyBlue;
    _pathLineColor = ZFClear;
    _valuePosition = kChartValuePositionDefalut;
    _valueTextColor = ZFBlack;
    _overMaxValueTextColor = ZFRed;
    _wavePatternType = kWavePatternTypeCurve;
    _valueLabelToWaveLinePadding = 0.f;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self drawGenericChart];
    }
    
    return self;
}

#pragma mark - 坐标轴

/**
 *  画坐标轴
 */
- (void)drawGenericChart{
    self.genericAxis = [[ZFGenericAxis alloc] initWithFrame:self.bounds];
    self.genericAxis.genericAxisDelegate = self;
    [self addSubview:self.genericAxis];
}

#pragma mark - 柱状条

/**
 *  画柱状条
 */
- (void)drawBar:(NSMutableArray *)valueArray{

        for (NSInteger i = 0; i < valueArray.count; i++) {
            CGFloat xPos = self.genericAxis.axisStartXPos + self.genericAxis.groupPadding + (_barWidth + self.genericAxis.groupPadding) * i;
            CGFloat yPos = self.genericAxis.yLineMaxValueYPos;
            CGFloat width = _barWidth;
            CGFloat height = self.genericAxis.yLineMaxValueHeight;
            
            ZFBar * bar = [[ZFBar alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
            bar.groupIndex = 0;
            bar.barIndex = i;
            
            //当前数值超过y轴显示上限时，柱状改为红色
            if ([self.genericAxis.xLineValueArray[i] floatValue] / self.genericAxis.yLineMaxValue <= 1) {
                bar.percent = ([self.genericAxis.xLineValueArray[i] floatValue] - self.genericAxis.yLineMinValue) / (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue);
                bar.barColor = [UIColor blueColor];
                bar.isOverrun = NO;
                
            }else{
                bar.percent = 1.f;
                bar.barColor = _overMaxValueBarColor;
                bar.isOverrun = YES;
            }
            bar.isShadow = _isShadow;
            bar.isAnimated = self.isAnimated;
            bar.opacity = self.opacity;
            bar.shadowColor = self.shadowColor;
            bar.gradientAttribute = _gradientColorArray ? _gradientColorArray.firstObject : nil;
            [bar strokePath];
            [self.barArray addObject:bar];
            [self.genericAxis addSubview:bar];
            
        }
        
   
}

#pragma mark - 画波浪path
- (void)drawWavePath{
    self.wave = [[ZFWave alloc] initWithFrame:CGRectMake(self.genericAxis.axisStartXPos, self.genericAxis.yLineMaxValueYPos, self.genericAxis.xLineWidth, self.genericAxis.yLineMaxValueHeight)];
    self.wave.valuePointArray = _valuePointArray;
    self.wave.pathColor = _pathColor;
    self.wave.pathLineColor = _pathLineColor;
    self.wave.padding = self.genericAxis.groupPadding;
    self.wave.wavePatternType = _wavePatternType;
    self.wave.isAnimated = self.isAnimated;
    self.wave.opacity = self.opacity;
    self.wave.gradientAttribute = _gradientAttribute;
    [self.genericAxis addSubview:self.wave];
    [self.wave strokePath];
}



#pragma mark - 重置Bar原始设置

- (void)resetBar:(ZFBar *)sender popoverLabel:(ZFPopoverLabel *)label{
    id subObject = self.genericAxis.xLineValueArray.firstObject;
    
    for (ZFBar * bar in self.barArray) {
        if (bar != sender) {
            if ([subObject isKindOfClass:[NSString class]]) {
                if (bar.isOverrun) {
                    bar.barColor = _overMaxValueBarColor;
                }else{
                    bar.barColor = !_isMultipleColorInSingleBarChart ? _colorArray.firstObject : _colorArray[bar.barIndex];
                }
            }else if ([subObject isKindOfClass:[NSArray class]]){
                bar.barColor = bar.isOverrun ? _overMaxValueBarColor : _colorArray[bar.groupIndex];
            }
            
            bar.isAnimated = NO;
            bar.opacity = self.opacity;
            [bar strokePath];
            //复原
            bar.isAnimated = self.isAnimated;
        }
    }
    
    if (!self.isShowAxisLineValue) {
        for (ZFPopoverLabel * popoverLabel in self.popoverLaberArray) {
            if (popoverLabel != label) {
                popoverLabel.hidden = YES;
            }
        }
    }
}

#pragma mark - 重置PopoverLabel原始设置

- (void)resetPopoverLabel:(ZFPopoverLabel *)sender{
    for (ZFPopoverLabel * popoverLabel in self.popoverLaberArray) {
        if (popoverLabel != sender) {
            popoverLabel.font = self.valueOnChartFont;
            popoverLabel.textColor = (UIColor *)self.valueTextColorArray[popoverLabel.groupIndex];
            popoverLabel.isAnimated = sender.isAnimated;
            [popoverLabel strokePath];
        }
    }
}

#pragma mark - 求每组宽度

/**
 *  求每组宽度
 */
- (CGFloat)cachedGroupWidth:(NSMutableArray *)array{
    id subObject = array.firstObject;
    if ([subObject isKindOfClass:[NSArray class]]) {
        return array.count * _barWidth + (array.count - 1) * _barPadding;
    }
    
    return _barWidth;
}

#pragma mark - 清除控件

/**
 *  清除之前所有柱状条
 */
- (void)removeAllBar{
    [self.barArray removeAllObjects];
    NSArray * subviews = [NSArray arrayWithArray:self.genericAxis.subviews];
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[ZFBar class]]) {
            [(ZFBar *)view removeFromSuperview];
        }
    }
}

/**
 *  清除柱状条上的Label
 */
- (void)removeLabelOnChart{
    [self.popoverLaberArray removeAllObjects];
    NSArray * subviews = [NSArray arrayWithArray:self.genericAxis.subviews];
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[ZFPopoverLabel class]]) {
            [(ZFPopoverLabel *)view removeFromSuperview];
        }
    }
}

#pragma mark - public method

/**
 *  重绘
 */
- (void)strokePath{
    [self.colorArray removeAllObjects];
    [self.valueTextColorArray removeAllObjects];
    
    if ([self.dataSource respondsToSelector:@selector(valueArrayInGenericChart:)]) {
        self.genericAxis.xLineValueArray = [NSMutableArray arrayWithArray:[self.dataSource valueArrayInGenericChart:self]];
    }
    
    if ([self.dataSource respondsToSelector:@selector(nameArrayInGenericChart:)]) {
        self.genericAxis.xLineNameArray = [NSMutableArray arrayWithArray:[self.dataSource nameArrayInGenericChart:self]];
    }
    
    if ([self.delegate respondsToSelector:@selector(colorArrayInGenericChart:)]) {
        _colorArray = [NSMutableArray arrayWithArray:[self.dataSource colorArrayInGenericChart:self]];
    }else{
        _colorArray = [NSMutableArray arrayWithArray:[[ZFMethod shareInstance] cachedRandomColor:self.genericAxis.xLineValueArray]];
    }
    
    if (self.isResetAxisLineMaxValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
            self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
        }else{
            NSLog(@"请返回一个最大值");
            return;
        }
    }else{
        self.genericAxis.yLineMaxValue = [[ZFMethod shareInstance] cachedMaxValue:self.genericAxis.xLineValueArray];
        
        if (self.genericAxis.yLineMaxValue == 0.f) {
            if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
                self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
            }else{
                NSLog(@"当前所有数据的最大值为0, 请返回一个固定最大值, 否则没法绘画图表");
                return;
            }
        }
    }
    
    if (self.isResetAxisLineMinValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMinValueInGenericChart:)]) {
            if ([self.dataSource axisLineMinValueInGenericChart:self] > [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray]) {
                self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
                
            }else{
                self.genericAxis.yLineMinValue = [self.dataSource axisLineMinValueInGenericChart:self];
            }

        }else{
            self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(axisLineSectionCountInGenericChart:)]) {
        self.genericAxis.yLineSectionCount = [self.dataSource axisLineSectionCountInGenericChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(barWidthInBarChart:)]) {
        _barWidth = [self.delegate barWidthInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(paddingForGroupsInBarChart:)]) {
        self.genericAxis.groupPadding = [self.delegate paddingForGroupsInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(paddingForBarInBarChart:)]) {
        _barPadding = [self.delegate paddingForBarInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(valueTextColorArrayInBarChart:)]) {
        id color = [self.delegate valueTextColorArrayInBarChart:self];
        id subObject = self.genericAxis.xLineValueArray.firstObject;
        if ([subObject isKindOfClass:[NSString class]]) {
            if ([color isKindOfClass:[UIColor class]]) {
                [self.valueTextColorArray addObject:color];
            }else if ([color isKindOfClass:[NSArray class]]){
                self.valueTextColorArray = [NSMutableArray arrayWithArray:color];
            }
            
        }else if ([subObject isKindOfClass:[NSArray class]]){
            if ([color isKindOfClass:[UIColor class]]) {
                for (NSInteger i = 0; i < self.genericAxis.xLineValueArray.count; i++) {
                    [self.valueTextColorArray addObject:color];
                }
                
            }else if ([color isKindOfClass:[NSArray class]]){
                self.valueTextColorArray = [NSMutableArray arrayWithArray:color];
            }
        }
        
    }else{
        id subObject = self.genericAxis.xLineValueArray.firstObject;
        if ([subObject isKindOfClass:[NSString class]]) {
            [self.valueTextColorArray addObject:_valueTextColor];
        }else if ([subObject isKindOfClass:[NSArray class]]){
            for (NSInteger i = 0; i < self.genericAxis.xLineValueArray.count; i++) {
                [self.valueTextColorArray addObject:_valueTextColor];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(gradientColorArrayInBarChart:)]) {
        _gradientColorArray = [NSMutableArray arrayWithArray:[self.delegate gradientColorArrayInBarChart:self]];
    }
    
    if (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue == 0) {
        NSLog(@"y轴数值显示的最大值与最小值相等，导致公式分母为0，无法绘画图表，请设置数值不一样的最大值与最小值");
        return;
    }
    
    self.genericAxis.groupWidth = [self cachedGroupWidth:self.genericAxis.xLineValueArray];
    
    if ([self.dataSource respondsToSelector:@selector(axisLineStartToDisplayValueAtIndex:)]) {
        self.genericAxis.displayValueAtIndex = [self.dataSource axisLineStartToDisplayValueAtIndex:self];
    }
    
    [self removeAllBar];
    [self removeLabelOnChart];
    self.genericAxis.xLineNameLabelToXAxisLinePadding = self.xLineNameLabelToXAxisLinePadding;
    self.genericAxis.isAnimated = self.isAnimated;
    self.genericAxis.isShowAxisArrows = self.isShowAxisArrows;
    self.genericAxis.valueType = self.valueType;
    self.genericAxis.numberOfDecimal = self.numberOfDecimal;
    self.genericAxis.separateLineStyle = self.separateLineStyle;
    self.genericAxis.separateLineDashPhase = self.separateLineDashPhase;
    self.genericAxis.separateLineDashPattern = self.separateLineDashPattern;
    [self.genericAxis strokePath];
    [self drawBar:self.genericAxis.xLineValueArray];
    
    [self.genericAxis bringSubviewToFront:self.genericAxis.yAxisLine];
    [self.genericAxis bringSectionToFront];
    [self bringSubviewToFront:self.topicLabel];
    [self strokePathWave];
}

/**
 *  重绘
 */
- (void)strokePathWave{
    if ([self.dataSource respondsToSelector:@selector(valueArrayInGenericChart:)]) {
        self.genericAxis.xLineValueArray = [NSMutableArray arrayWithArray:[self.dataSource valueArrayInGenericChart:self]];
        //如果数组里存的不是字符串，则return
        id subObject = self.genericAxis.xLineValueArray.firstObject;
        if (![subObject isKindOfClass:[NSString class]]) {
            return;
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(nameArrayInGenericChart:)]) {
        self.genericAxis.xLineNameArray = [NSMutableArray arrayWithArray:[self.dataSource nameArrayInGenericChart:self]];
    }
    
    if (self.isResetAxisLineMaxValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
            self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
        }else{
            NSLog(@"请返回一个最大值");
            return;
        }
    }else{
        self.genericAxis.yLineMaxValue = [[ZFMethod shareInstance] cachedMaxValue:self.genericAxis.xLineValueArray];
        
        if (self.genericAxis.yLineMaxValue == 0.f) {
            if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
                self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
            }else{
                NSLog(@"当前所有数据的最大值为0, 请返回一个固定最大值, 否则没法绘画图表");
                return;
            }
        }
    }
    
    if (self.isResetAxisLineMinValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMinValueInGenericChart:)]) {
            if ([self.dataSource axisLineMinValueInGenericChart:self] > [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray]) {
                self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
                
            }else{
                self.genericAxis.yLineMinValue = [self.dataSource axisLineMinValueInGenericChart:self];
            }
            
        }else{
            self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(axisLineSectionCountInGenericChart:)]) {
        self.genericAxis.yLineSectionCount = [self.dataSource axisLineSectionCountInGenericChart:self];
    }
    
//    if ([self.delegate respondsToSelector:@selector(groupWidthInWaveChart:)]) {
//        self.genericAxis.groupWidth = [self.delegate groupWidthInWaveChart:self];
//    }
    
//    if ([self.delegate respondsToSelector:@selector(paddingForGroupsInWaveChart:)]) {
//        self.genericAxis.groupPadding = [self.delegate paddingForGroupsInWaveChart:self];
//    }
    
//    if ([self.delegate respondsToSelector:@selector(gradientColorInWaveChart:)]) {
//        _gradientAttribute = [self.delegate gradientColorInWaveChart:self];
//    }
    
    if (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue == 0) {
        NSLog(@"y轴数值显示的最大值与最小值相等，导致公式分母为0，无法绘画图表，请设置数值不一样的最大值与最小值");
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(axisLineStartToDisplayValueAtIndex:)]) {
        self.genericAxis.displayValueAtIndex = [self.dataSource axisLineStartToDisplayValueAtIndex:self];
    }
    
    [self removeAllSubview];
    self.genericAxis.xLineNameLabelToXAxisLinePadding = self.xLineNameLabelToXAxisLinePadding;
    self.genericAxis.isAnimated = self.isAnimated;
    self.genericAxis.isShowAxisArrows = self.isShowAxisArrows;
    self.genericAxis.valueType = self.valueType;
    self.genericAxis.numberOfDecimal = self.numberOfDecimal;
    self.genericAxis.separateLineStyle = self.separateLineStyle;
    self.genericAxis.separateLineDashPhase = self.separateLineDashPhase;
    self.genericAxis.separateLineDashPattern = self.separateLineDashPattern;
    [self.genericAxis strokePath];
    _valuePointArray = [NSMutableArray arrayWithArray:[self cachedValuePointArray:self.genericAxis.xLineValueArray]];
    [self drawWavePath];
//    [self setValueLabelOnChart];
    [self.genericAxis bringSubviewToFront:self.genericAxis.yAxisLine];
    [self.genericAxis bringSectionToFront];
    [self bringSubviewToFront:self.topicLabel];
}

/**
 *  清除所有子控件
 */
- (void)removeAllSubview{
    [self.popoverLaberArray removeAllObjects];
    NSArray * subviews = [NSArray arrayWithArray:self.genericAxis.subviews];
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[ZFWave class]] || [view isKindOfClass:[ZFPopoverLabel class]]) {
            [view removeFromSuperview];
        }
    }
}
#pragma mark - public method


/**
 *  计算点的位置
 */
- (NSMutableArray *)cachedValuePointArray:(NSMutableArray *)valueArray{
    NSMutableArray * valuePointArray = [NSMutableArray array];
    for (NSInteger i = 0; i < valueArray.count; i++) {
        CGFloat percent = ([valueArray[i] floatValue] - self.genericAxis.yLineMinValue) / (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue);
        if (percent > 1) {
            percent = 1;
        }
        
        CGFloat height = self.genericAxis.yLineMaxValueHeight * percent;
        CGFloat xPos = self.genericAxis.groupPadding + self.genericAxis.groupWidth * 0.5 + (self.genericAxis.groupPadding + self.genericAxis.groupWidth) * i;
        CGFloat yPos = self.genericAxis.axisStartYPos - self.genericAxis.yLineMaxValueYPos - height;
        
        //判断高度是否为0
        BOOL isHeightEqualZero = height == 0 ? YES : NO;
        NSDictionary * dict = @{ZFWaveChartXPos:@(xPos), ZFWaveChartYPos:@(yPos), ZFWaveChartIsHeightEqualZero:@(isHeightEqualZero)};
        [valuePointArray addObject:dict];
    }
    
    return valuePointArray;
}
#pragma mark - ZFGenericAxisDelegate

- (void)genericAxisDidScroll:(UIScrollView *)scrollView{
    if ([self.dataSource respondsToSelector:@selector(genericChartDidScroll:)]) {
        [self.dataSource genericChartDidScroll:scrollView];
    }
}

#pragma mark - 重写setter,getter方法

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.genericAxis.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setUnit:(NSString *)unit{
    self.genericAxis.unit = unit;
}

- (void)setUnitColor:(UIColor *)unitColor{
    self.genericAxis.unitColor = unitColor;
}

- (void)setAxisLineNameFont:(UIFont *)axisLineNameFont{
    self.genericAxis.xLineNameFont = axisLineNameFont;
}

- (void)setAxisLineValueFont:(UIFont *)axisLineValueFont{
    self.genericAxis.yLineValueFont = axisLineValueFont;
}

- (void)setAxisLineNameColor:(UIColor *)axisLineNameColor{
    self.genericAxis.xLineNameColor = axisLineNameColor;
}

- (void)setAxisLineValueColor:(UIColor *)axisLineValueColor{
    self.genericAxis.yLineValueColor = axisLineValueColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.genericAxis.axisLineBackgroundColor = backgroundColor;
}

- (void)setXAxisColor:(UIColor *)xAxisColor{
    self.genericAxis.xAxisColor = xAxisColor;
}

- (void)setYAxisColor:(UIColor *)yAxisColor{
    self.genericAxis.yAxisColor = yAxisColor;
}

- (void)setSeparateColor:(UIColor *)separateColor{
    self.genericAxis.separateColor = separateColor;
}

- (void)setIsShowXLineSeparate:(BOOL)isShowXLineSeparate{
    self.genericAxis.isShowXLineSeparate = isShowXLineSeparate;
}

- (void)setIsShowYLineSeparate:(BOOL)isShowYLineSeparate{
    self.genericAxis.isShowYLineSeparate = isShowYLineSeparate;
}

#pragma mark - 懒加载

- (NSMutableArray *)barArray{
    if (!_barArray) {
        _barArray = [NSMutableArray array];
    }
    return _barArray;
}


- (NSMutableArray *)valueTextColorArray{
    if (!_valueTextColorArray) {
        _valueTextColorArray = [NSMutableArray array];
    }
    return _valueTextColorArray;
}

@end
