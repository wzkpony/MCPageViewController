//
//  MCPageViewController.m
//  Demo_pageViewController管理多页面
//
//  Created by goulela on 2017/8/17.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "MCPageViewController.h"


@interface MCPageViewController ()
<
UIScrollViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource
>
{
    NSInteger _curPage;
}
@property (nonatomic, strong) UIScrollView * titleScrollView;
//标题滚动视图
@property (nonatomic, strong) UIView * indicatorView;
//分页控制器
@property (nonatomic, strong) UIPageViewController * pageVC;
@property (nonatomic, strong) UIView * lineView;



/**
 *  标题按钮的数组
 *  用来改变按钮的状态
 */
@property (nonatomic, strong) NSMutableArray * titleButtonArrayM;
@property (nonatomic, assign) CGFloat   blockWidth;           // 标题块的宽度  根据标题文字长度计算
@property (nonatomic, strong) NSArray * titleArray;           // 存放标题的数组
@property (nonatomic, strong) NSArray * vcArray;              // 控制器的数组
@property (nonatomic, strong) UIColor * blockNormalColor;     // 标题块的默认颜色
@property (nonatomic, strong) UIColor * blockSelectedColor;   // 标题块的选择颜色
@property (nonatomic, assign) NSInteger currentPage;          // 需要显示的页面  默认为第零页


@end

@implementation MCPageViewController

#define kReuseCell @"cell"
#define kWidth          self.view.bounds.size.width
#define kHeigth         self.view.bounds.size.height


- (void)initWithTitleArray:(NSArray *)titles vcArray:(NSArray *)vcArray blockNormalColor:(UIColor *)blockNormalColor blockSelectedColor:(UIColor *)blockSelectedColor currentPage:(NSInteger)currentPage {
    
    if (titles.count != vcArray.count) {
        printf("-----------------\n\n标题数组和控制器数组个数不一致\n\n-------------");
        return;
    }
    
    
    self.titleArray = titles;
    self.vcArray = vcArray;
    self.blockNormalColor = blockNormalColor;
    self.blockSelectedColor = blockSelectedColor;
    
    [self achieve];
    
    
    [self jumpToSubViewController:currentPage];
}



// 避免子类重写viewDidLoad方法导致不能实现下面的两个方法
- (void)achieve {
    [self reference_baseSetting];
    [self reference_initUI];
}

-(void)jumpToSubViewController:(NSInteger)index {
    [self jumpToVC:self.titleButtonArrayM[index]];
}


#pragma mark - 系统代理
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == _vcArray.count -1) {
        return nil;
    }
    return _vcArray[index+1];
}
//返回上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }
    return _vcArray[index-1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *sub = pageViewController.viewControllers[0];
    NSInteger index = 0;
    for (UIViewController *VC in _vcArray) {
        
        if ([VC isEqual:sub]) { _curPage = index; }
        index++;
    }
    
    UIButton * btn = (UIButton *)[self.view.window viewWithTag:_curPage + 1000];
    [self titleButtonClicked:btn];
    [self setScrollViewOffSet:btn];
}


//设置偏移
- (void)setScrollViewOffSet:(UIButton *)sender {
    
    if (self.isLeftPosition) {
        return;
    }
    
    int count = kWidth * 0.5 / self.blockWidth;
    if (count % 2 == 0) { count --; }
    CGFloat offsetX = sender.frame.origin.x - count * self.blockWidth;
    
    if (offsetX<0) { offsetX=0; }
    CGFloat maxOffsetX= _titleScrollView.contentSize.width - kWidth;
    
    if (offsetX > maxOffsetX) { offsetX = maxOffsetX; }
    [UIView animateWithDuration:.2 animations:^{
        [_titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }];
}


#pragma mark - 点击事件
- (void)titleButtonClicked:(id)sender {
    NSInteger tagNum = [sender tag];
    
    _curPage = tagNum - 1000;
    
    if (_curPage < 0) { _curPage = 1; }
    
    NSString * title = [self.titleArray objectAtIndex:_curPage];
    CGFloat width = [title boundingRectWithSize:CGSizeMake(1000, self.blockFont) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.blockFont]} context:nil].size.width;
    
    for (UIButton * button in self.titleButtonArrayM) {
        if (tagNum != button.tag) {
            [button setTitleColor:self.blockNormalColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:self.blockFont];
        } else {
            [UIView animateKeyframesWithDuration:0.2
                                           delay:0.0
                                         options:UIViewKeyframeAnimationOptionLayoutSubviews
                                      animations:^{
                                          
                                          _indicatorView.center = CGPointMake(button.center.x, self.barHeight-0.75);
                                          _indicatorView.bounds = CGRectMake(0, 0, width, 1.5);
                                          
                                      }
                                      completion:^(BOOL finished) {
                                          button.titleLabel.font = [UIFont systemFontOfSize:self.blockFont + 1];
                                          [button setTitleColor:self.blockSelectedColor forState:UIControlStateNormal];
                                      }];
        }
    }
}

- (void)jumpToVC:(UIButton *)btn {
    //要跳转到的vc索引
    //direction：0代表前进，1代表后退
    [self titleButtonClicked:btn];
    
    NSInteger toPage = btn.tag - 1000;
    [_pageVC setViewControllers:@[_vcArray[toPage]] direction:_curPage>toPage animated:NO completion:^(BOOL finished) {
        _curPage = toPage;
    }];
}

#pragma mark - 实现方法
- (void)reference_baseSetting {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_barHeight == 0) { _barHeight = 44; }
    
    if (_barHeight < 0) { _barHeight = 0; }
    
    if (_blockFont < 14) { _blockFont = 15; }
    
    if (_blockColor == nil) { _blockColor = [UIColor whiteColor]; }
    
    CGFloat W = 0.0;
    CGFloat allW = 0.0;
    for (NSString * str in self.titleArray) {
        CGSize size = CGSizeMake(999, 20);
        NSDictionary * dict =@{NSFontAttributeName : [UIFont systemFontOfSize:self.blockFont]};
        CGFloat width = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size.width + 15;
        
        if (width > W) {
            W = width;
        }
        allW += width;
    }
    
    if (self.isLeftPosition) {
        self.blockWidth = W;
    } else {
        if (allW >= kWidth) {
            self.blockWidth = W;
        } else {
            self.blockWidth = kWidth / self.titleArray.count;
        }
    }
}

- (void)reference_initUI {
    self.titleScrollView.frame = CGRectMake(0, 0, kWidth, self.barHeight);
    [self.view addSubview:self.titleScrollView];
    
    self.lineView.frame = CGRectMake(0, self.barHeight, kWidth, 1.5);
    [self.view addSubview:self.lineView];
    
    self.pageVC.view.frame = CGRectMake(0, self.barHeight + 1, kWidth, kHeigth - self.barHeight);
    [self.view addSubview:self.pageVC.view];
    
    
    //创建按钮
    for (int i = 0; i<self.titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*self.blockWidth, 0, self.blockWidth, self.barHeight);
        btn.backgroundColor = self.blockColor;
        btn.titleLabel.font = [UIFont systemFontOfSize:self.blockFont];
        [btn setTitle:[NSString stringWithFormat:@"%@",self.titleArray[i]] forState:UIControlStateNormal];
        [btn setTitleColor:self.blockNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.blockSelectedColor forState:UIControlStateNormal];
        btn.tag = 1000 + i;
        //添加点击事件
        [btn addTarget:self action:@selector(jumpToVC:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleButtonArrayM addObject:btn];
        [_titleScrollView addSubview:btn];
    }
    
    
    self.titleScrollView.contentSize = CGSizeMake(self.blockWidth*self.titleArray.count, 0);
    self.titleScrollView.contentSize = CGSizeMake(self.blockWidth*self.titleArray.count, 0);
    
    NSString * title = [self.titleArray objectAtIndex:0];
    CGFloat width = [title boundingRectWithSize:CGSizeMake(1000, self.blockFont) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.blockFont]} context:nil].size.width;
    self.indicatorView.frame = CGRectMake((self.blockWidth - width)/2 + self.currentPage * self.blockWidth, self.barHeight-1.5, width, 1.5);
    [self.titleScrollView addSubview:self.indicatorView];
}




#pragma mark - setter & getter
- (UIScrollView *)titleScrollView {
    if (_titleScrollView == nil) {
        self.titleScrollView = [[UIScrollView alloc] init];
        self.titleScrollView.showsHorizontalScrollIndicator = NO;
        self.titleScrollView.backgroundColor = [UIColor whiteColor];
    } return _titleScrollView;
}

- (UIView *)indicatorView {
    if (_indicatorView == nil) {
        self.indicatorView = [[UIView alloc] init];
        self.indicatorView.backgroundColor = self.blockSelectedColor;
    } return _indicatorView;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:247/255.0f alpha:1];
    } return _lineView;
}

- (NSMutableArray *)titleButtonArrayM {
    if (_titleButtonArrayM == nil) {
        self.titleButtonArrayM = [NSMutableArray arrayWithCapacity:0];
    } return _titleButtonArrayM;
}

- (UIPageViewController *)pageVC {
    if (!_pageVC) {
        self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        
        [self.pageVC setViewControllers:@[self.vcArray[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        
        // 遍历pageVC.view的子视图,找到scrollView.设置代理
        for (UIView * view in self.pageVC.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                [view setValue:self forKey:@"delegate"];
            }
        }
    } return _pageVC;
}



@end

