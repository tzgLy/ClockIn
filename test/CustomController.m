//
//  CustomController.m
//  test
//
//  Created by 田智广 on 2019/3/4.
//  Copyright © 2019年 田智广. All rights reserved.
//

#import "CustomController.h"
#import "ViewController.h"

@interface CustomController ()
@property (weak, nonatomic) IBOutlet UITextField *textF1;
@property (weak, nonatomic) IBOutlet UITextField *textF2;

@end

@implementation CustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)conBtnClick:(id)sender {
    
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *vc=[sb instantiateViewControllerWithIdentifier:@"VVC"];
    vc.address=self.textF2.text;
    vc.distance=self.textF1.text;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

@end
