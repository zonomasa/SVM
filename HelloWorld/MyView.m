//
//  MyView.m
//  HelloWorld
//
//  Created by TATEZONO Masaki on 2013/01/19.
//  Copyright (c) 2013年 TATEZONO Masaki. All rights reserved.
//

#import "MyView.h"

#define MAX_ARRAY_SIZE 20

@interface  UIView()
@end

@implementation MyView


float R    = 4.0f; // 半径
float LINE = 4.0f; // 線の太さ



int nearObjIndex; // 最も近いteacherのIndexを保持

 
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // 背景色を透明に
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

/**
 * タッチ
 */
- (void)startTouch:(CGPoint)location{
    NSLog(@"startTouch %.2f, %.2f", location.x, location.y);
    
    nearObjIndex = [self getNearObject:location];
    NSLog(@"nearObj:%d",nearObjIndex);
}

- (void)movedTouch:(CGPoint)location{
    NSLog(@"startTouch %.2f, %.2f", location.x, location.y);
    CGRect r = self.bounds;
    if ( nearObjIndex != -1){
        teacher[nearObjIndex][0] = location.x/r.size.width;
        teacher[nearObjIndex][1] = location.y/r.size.height;
    }
    // 再描画を依頼
    [self setNeedsDisplay];
    
}

- (void)endTouch:(CGPoint)location{
    NSLog(@"startTouch %.2f, %.2f", location.x, location.y);
    CGRect r = self.bounds;
    if ( nearObjIndex != -1){
        teacher[nearObjIndex][0] = location.x/r.size.width;
        teacher[nearObjIndex][1] = location.y/r.size.height;
    }
    // 再描画を依頼
    [self setNeedsDisplay];
}


/**
 * 引数のlocationから最も近い教師データオブジェクトを返す。
 * 近いものがないときは"-1"を返す。
 * "近い"のしきい値はif文に直書きした。
 */
- (int)getNearObject:(CGPoint)touchPoint{
    float distance = 100.0f;
    int index = -1;
    
    CGRect r = self.bounds;
    
    for (int i = 0; i < sizeof(teacher)/sizeof(teacher[0]);i++){
        CGPoint teacherPoint = CGPointMake(teacher[i][0]*r.size.width, teacher[i][1]*r.size.height);
        float tmp = [self calcDistance:touchPoint withTeacher:teacherPoint];
        NSLog(@"tmp:%f",tmp);
        
        if( distance > tmp){
            index = i;
            distance = tmp;
        }
                        
    }
    
    if ( distance < 10.0f ){
        return index;
    }
    return -1;
}


- (float)calcDistance:(CGPoint)touchPoint withTeacher:(CGPoint)teacherPoint{
    NSLog(@"touchX:%f,touchY:%f,teacherX:%f,teacherY:%f",touchPoint.x,touchPoint.y,teacherPoint.x,teacherPoint.y);
    return sqrt(powf((touchPoint.x - teacherPoint.x),2) + powf((touchPoint.y - teacherPoint.y),2) );
}


/**
 * UIViewを描画する時に呼ばれる
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];



    // 参考:http://seiichirou.jp/2011/03/08/uiview%E3%81%AB%E5%9B%B3%E5%BD%A2%E3%82%92%E7%9B%B4%E6%8E%A5%E6%8F%8F%E7%94%BB%E3%81%99%E3%82%8B/

    
    // キャンバスのサイズを取得
    CGRect r = self.bounds;
    // コンテキストをゲット
    CGContextRef context = UIGraphicsGetCurrentContext();

    for(int i=0;i < sizeof(teacher)/sizeof(teacher[0]);i++){
        CGRect rectEllipse = CGRectMake((int)r.size.width*teacher[i][0]-R, (int)r.size.height*teacher[i][1]-R, R*2, R*2);
        if (teacher[i][2] == 1){
            // 正のポイントをプロット
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 0.5); // 青
        }else{
            // 負のポイントをプロット
            CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5); // 赤
        }
        CGContextSetLineWidth(context, LINE);
        CGContextStrokeEllipseInRect(context, rectEllipse);
    }
    
    [self drawSVM];
}

/********** SVM主要部分 ************/

#define DIM 2

#define ARRAY_SIZE 5
#define ETA 0.5f

#define LAMDA_INIT 0.1f

float lamda[ARRAY_SIZE];


/**
 * g(x) = w_t * x + b
 *
 */
- (void)drawSVM{
    float w[DIM];
    float b;

    // lamdaの初期化
    for (int i = 0; i < ARRAY_SIZE; i++){
        lamda[i] = LAMDA_INIT;
    }

    // lamdaの最適解を求めてくる
    [self calcLamda];
    
    // wを計算する。
    for (int dim = 0; dim < DIM  ; dim++){
        float sum;

        for (int i = 0; i < ARRAY_SIZE; i++){
            sum +=lamda[i]*teacher[i][2]*teacher[i][dim];
        }
        w[dim] = sum;
    }

    int i;
    for( i = 0 ; i <ARRAY_SIZE;i++){
    if (lamda[i] > 0)
            break;
    }
    
    // bを計算する
    b = teacher[i][2]-(w[0]*teacher[i][0] + w[1]*teacher[i][1]);
    

    /**** ここから先は2次元依存処理***/
    float x_y0 = b * -1 / w[0];
    float x_y1 = (b * -1 + w[1] * -1) / w[0];
    float y_x0 = b * -1 / w[1];
    float y_x1 = (b * -1 + w[0] * -1) / w[1];
    NSLog(@"x_y0:%f",x_y0);
    NSLog(@"x_y1:%f",x_y1);
    NSLog(@"y_x0:%f",y_x0);
    NSLog(@"y_x1:%f",y_x1);

    
    CGRect r = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (x_y0 > 0){
        CGContextMoveToPoint(context, r.size.width*x_y0, r.size.height*0);  // 始点
    }else{
        CGContextMoveToPoint(context, r.size.width*x_y1, r.size.height*1);  // 始点
    }
    if (y_x0 > 0){
        CGContextAddLineToPoint(context,r.size.width*0, r.size.height*y_x0);  // 終点
    }else{
        CGContextAddLineToPoint(context,r.size.width*1, r.size.height*y_x1);  // 終点
    }
    CGContextStrokePath(context);  // 描画！

    /************** デバッグ出力 ****************/
    for (int dim = 0; dim <DIM; dim++){
        NSLog(@"w[%d]:%f",dim,w[dim]);
    }
    for (int i = 0; i <ARRAY_SIZE; i++){
        NSLog(@"lamda[%d]:%f",i,lamda[i]);
    }
    NSLog(@"b:%f",b);
    
}


- (void)calcLamda{

    int try= 0;
    do {
        // lamdaベクトルを求める
        for (int i = 0; i < ARRAY_SIZE;i++){
            lamda[i] +=[self calcDelta:i];
        }
        try++;

    } while (try < 1000);
}

/**
 * indexのみを引数に取り、Deltaを計算する。
 * ETA(1 - sum_j=1_n Lamdaj YiYj Xj_t Xj)
 */
- (float)calcDelta:(int)index{
    
    float sum = 0;
    
    for (int j = 0; j < ARRAY_SIZE; j++){
        float tmp = lamda[j]*teacher[index][2]*teacher[j][2]*[self calcMatrix:index withJ:j];
        sum += tmp;
//        NSLog(@"tmp:%f",tmp);
        
    }
    
    return ETA*(1-sum);
}

/**
 * X_i_t*X_j
 */
- (float)calcMatrix:(int)index withJ:(int)j{
    return teacher[index][0]*teacher[j][0] + teacher[index][1]*teacher[j][1];
}

// 教師データ
float teacher[ARRAY_SIZE][3] = {
    {   0.519722518,0.406180582,-1},
    {	0.24990739,0.551808206,1},
    {	0.424894685,0.102030199,-1},
    {	0.808888189,0.302231297,-1},
    {	0.567157051,0.260726765,1},

   /*
    {	0.940654474,0.378918219,-1},
    {	0.656379021,0.5096965,1},
    {	0.148165211,0.341863868,-1},
    {	0.20159406,0.066585565,-1},
    {	0.506910938,0.583646295,-1},
    {	0.409933035,0.163659055,-1},
    {	0.079184439,0.881702332,-1},
    {	0.395674109,0.126755713,-1},
    {	0.975751003,0.061926927,-1},
    {	0.816507204,0.128577988,-1},
    {	0.276189854,0.671887301,1},
    {	0.114233908,0.102541988,-1},
    {	0.586359147,0.844506965,-1},
    {	0.449444434,0.205108953,1},
    {	0.102792483,0.736303647,-1},
    {	0.283084527,0.384471181,1},
    {	0.782829506,0.37990752,1},
    {	0.918516096,0.957903625,-1},
    {	0.958708953,0.691956745,-1},
    {	0.683162229,0.547576355,1},
    {	0.670740332,0.552130316,1},
    {	0.373994398,0.210310499,1},
    {	0.846083099,0.593438822,-1},
    {	0.214168834,0.563449217,1},
    {	0.671005848,0.159759988,-1},
    {	0.512222836,0.751803246,1},
    {	0.128647738,0.660757652,-1},
    {	0.521783582,0.647888944,1},
    {	0.988883997,0.041066129,-1},
    {	0.129127722,0.37468461,-1},
    {	0.86548111,0.101305142,-1},
    {	0.455100066,0.749073837,1},
    {	0.565130953,0.362411544,1},
    {	0.292648259,0.309882273,1},
    {	0.371620935,0.900527576,-1},
    {	0.656935054,0.97048776,-1},
    {	0.624442483,0.860955667,-1},
    {	0.466668652,0.364159771,1},
    {	0.57980833,0.508935479,-1},
    {	0.384062095,0.085161234,-1},
    {	0.671821405,0.169348614,-1},
    {	0.712806472,0.683683993,1},
    {	0.764106993,0.506109508,1},
    {	0.10643497,0.50916941,-1},
    {	0.168838495,0.374187466,-1}
*/
};

@end
