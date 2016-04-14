//
//  ICOBaseViewController.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOMenuViewController.h"

@interface ICOMenuViewController ()
{
    bool _isLarge;
}

- (IBAction)tappedBack:(id)sender;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *onTapBack;
- (IBAction)onPlaying:(id)sender;
- (IBAction)onSearch:(id)sender;

- (IBAction)onFavorites:(id)sender;

@end

@implementation ICOMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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




- (IBAction)tappedBack:(id)sender {
    
    
    [[self navigator] performNavigatorAction:ICONavigatorActionPresentCenter];
    
}


- (IBAction)onPlaying:(id)sender {
    
    [[self navigator] performNavigatorAction:ICONavigatorActionPresentCenter];
    
    
    
}

- (IBAction)onSearch:(id)sender {
    
    [[self navigator] performNavigatorAction:ICONavigatorActionPresentRight withParams:@{@"controllerId":[NSNumber numberWithInt:2]}];
    
}

- (IBAction)onFavorites:(id)sender {
    
    [[self navigator] performNavigatorAction:ICONavigatorActionPresentRight withParams:@{@"controllerId":[NSNumber numberWithInt:1]}];
    
}
@end
