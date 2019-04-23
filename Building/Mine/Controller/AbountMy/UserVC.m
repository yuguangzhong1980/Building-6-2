//
//  UserVC.m
//  Building
//
//  Created by Mac on 2019/3/14.
//  Copyright © 2019年 Macbook Pro. All rights reserved.
//

#import "UserVC.h"

@interface UserVC ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation UserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //读取文本文件
    [self readFromText];
    [self.navigationItem setTitle:@"用户须知"];
}

-(void)readFromText{
    
    NSError *error;
    NSString *textFieldContents=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"readme" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"--textFieldContents---%@-----",textFieldContents);
//    if (textFieldContents==nil) {
//        NSLog(@"---error--%@",[error localizedDescription]);
//    }
//    NSArray *lines=[textFieldContents componentsSeparatedByString:@"\n"];
    
    
    self.textView.text=textFieldContents;
}

@end
