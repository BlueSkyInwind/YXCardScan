//
//  ViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "YXBankSacnViewController.h"
#import "YX_BankCardScanManager.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bankcardBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)bankcardScanclick:(id)sender {
    
    [YX_BankCardScanManager shareInstance].isPush = false;
    [YX_BankCardScanManager shareInstance].backImageName = @"icon_lanjiantou@2x";
    [YX_BankCardScanManager shareInstance].nagavigationVC.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [[YX_BankCardScanManager shareInstance] CardStart:self finish:^(YXBankCardModel * _Nullable result) {
        NSLog(@"%@",result);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
