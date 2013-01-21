//
//  MyView.h
//  HelloWorld
//
//  Created by TATEZONO Masaki on 2013/01/19.
//  Copyright (c) 2013年 TATEZONO Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyView : UIView{
        int moved;
}
-(void)startTouch:(CGPoint)location;
-(void)movedTouch:(CGPoint)location;
-(void)endTouch:(CGPoint)location;
@end