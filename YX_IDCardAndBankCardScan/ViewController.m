//
//  ViewController.m
//  YX_IDCardAndBankCardScan
//
//  Created by admin on 2017/10/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "YXBankSacnViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bankcardBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


- (IBAction)bankcardScanclick:(id)sender {
    YXBankSacnViewController * bankScanVC = [[YXBankSacnViewController alloc]init];
    [self.navigationController pushViewController:bankScanVC animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
