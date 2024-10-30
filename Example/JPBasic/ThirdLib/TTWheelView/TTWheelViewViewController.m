//
//  TTWheelViewViewController.m
//  JPBasic
//
//  Created by aa on 2022/3/8.
//  Copyright © 2022 zhoujianping24@hotmail.com. All rights reserved.
//

#import "TTWheelViewViewController.h"

@interface TTWheelViewViewController () <TTWheelDataSource, TTWheelViewDelegate>
@property (nonatomic, weak) TTWheelView *wheelView;
@end

@implementation TTWheelViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    
    TTWheelView *wheelView = [[TTWheelView alloc] initWithradiu:200 divitionCount:60];
    wheelView.delegate = self;
    wheelView.dataSource = self;
    wheelView.stopInCell = YES;
    wheelView.backgroundColor = JPRandomColor;
    wheelView.maskOutCircle = YES;
    [self.view addSubview:wheelView];
    self.wheelView = wheelView;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.wheelView.jp_origin = CGPointMake(JPHalfOfDiff(JPPortraitScreenWidth, self.wheelView.jp_width), JPHalfOfDiff(JPPortraitScreenHeight, self.wheelView.jp_height));
}

- (TTWheelCell *)cellAtIndex:(NSInteger)index forWheel:(TTWheelView *)wheel {
    
    TTWheelCell * cell = [wheel dequeenCellForIdentifire:@"cell"];
    if (!cell) {
        JPLog(@"hei");
        cell = [[TTWheelCell alloc] initWithReuserIdentifire:@"cell"];
        cell.backgroundColor = JPRandomColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = JPRandomColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 199;
        [cell addSubview:label];
    }
    
    UILabel *label = [cell viewWithTag:199];
    label.text = [NSString stringWithFormat:@"%zd", index];
    
    return cell;
}

- (NSUInteger)dataCountForWheel:(TTWheelView *)wheel {
    JPLog(@"ha");
    return 60;
}

- (CGFloat)wheel:(TTWheelView *)wheel radiuForIndex:(NSInteger)index {
    return 200- 10 -32-110*0.14;
}

- (CGSize)wheel:(TTWheelView *)wheel sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(60, 60);
}

- (void)wheel:(TTWheelView *)wheel cellClicked:(TTWheelCell *)cell {
    JPLog(@"hi");
}

- (void)wheelDidLayouted:(TTWheelView *)wheel {
    
}

- (void)wheelDidScroll:(TTWheelView *)wheel {
    
}

- (void)wheelDidStopScroll:(TTWheelView *)wheel {
    
}

@end
