//
//  ViewController.m
//  HelloWorld
//
//  Created by TATEZONO Masaki on 2013/01/18.
//  Copyright (c) 2013年 TATEZONO Masaki. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"

@interface ViewController (){
    MyView *_myView;
}
@end

@implementation ViewController




- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // 正方形で下に設置する
    CGRect rect = self.view.bounds;
    rect.size.height = rect.size.width;
    _myView = [[MyView alloc] initWithFrame:rect];
    [self.view addSubview:_myView];
    
}




/**
 * タッチイベント開始
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch* touch = (UITouch*)[touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    NSLog(@"begin %.2f, %.2f", location.x, location.y);
    [_myView startTouch:location];

}

/**
 * タッチ移動
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch* touch = (UITouch*)[touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    NSLog(@"begin %.2f, %.2f", location.x, location.y);
    [_myView movedTouch:location];
}

/**
 * タッチイベント終了
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    // 虹をフェードアウトする
    UITouch* touch = (UITouch*)[touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    NSLog(@"end %.2f, %.2f", location.x, location.y);
    [_myView endTouch:location];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
