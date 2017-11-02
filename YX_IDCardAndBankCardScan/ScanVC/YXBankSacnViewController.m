//
//  YXBankSacnViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXBankSacnViewController.h"
#import "YXScanBankCardView.h"

@interface YXBankSacnViewController ()
@property (nonatomic,strong)YXScanBankCardView * scanBankCardView;

@end

@implementation YXBankSacnViewController

-(YXScanBankCardView *)scanBankCardView{
    if (!_scanBankCardView) {
        _scanBankCardView = [[YXScanBankCardView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _scanBankCardView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"银行卡扫描";
    [self.view insertSubview:self.scanBankCardView atIndex:0];

    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
