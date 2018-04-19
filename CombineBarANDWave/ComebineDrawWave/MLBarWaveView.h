//
//  MLBarWaveView.h
//  CombineBarANDWave
//
//  Created by Maple on 19/04/2018.
//  Copyright © 2018 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLBarWaveView : UIView
@property (strong,nonatomic)NSArray *xAxisDataSouce;
@property (strong,nonatomic)NSArray *yAxisDataSource;
@property (assign,nonatomic) CGFloat *maxY;
@end
