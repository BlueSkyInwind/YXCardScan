//
//  YXBankSacnViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "YXBankSacnViewController.h"
#import "YXScanBankCardView.h"
#import "UIImage+Extend.h"
#import "YXScanResultViewController.h"

@interface YXBankSacnViewController ()
@property (nonatomic,strong)YXScanBankCardView * scanBankCardView;

@end

@implementation YXBankSacnViewController
#pragma mark - 检测是模拟器还是真机
#if TARGET_IPHONE_SIMULATOR
// 是模拟器的话，提示“请使用真机测试！！！”
-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"银行卡扫描";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"模拟器没有摄像设备"  message:@"请使用真机测试！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#else

#pragma mark - 懒加载
#pragma mark device

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
    self.scanManager.sessionPreset = AVCaptureSessionPresetHigh;
    if ([self.scanManager configBankScanManager]) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:view atIndex:0];
        AVCaptureVideoPreviewLayer * previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.scanManager.captureSession];
        previewLayer.frame = [UIScreen mainScreen].bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [view.layer addSublayer:previewLayer];
        [self.scanManager startSession];
    }
    __weak typeof (self) weakSelf = self;
    self.scanManager.bankCardesult = ^(id result) {
        YXBankCardModel * model = (YXBankCardModel *)result;
        [weakSelf showResult:model];
    };
}

- (void)showResult:(YXBankCardModel *)result {
    YXScanResultViewController * resultVC= [[YXScanResultViewController alloc]init];
    resultVC.bankCardModel  = result;
    [self.navigationController pushViewController:resultVC animated:true];
    
//    NSString *message = [NSString stringWithFormat:@"%@\n%@", result.bankName, result.bankNumber];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:message preferredStyle:UIAlertControllerStyleActionSheet];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
    
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
#endif
@end
