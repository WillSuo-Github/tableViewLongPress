//
//  ViewController.m
//  tableViewLongPress
//
//  Created by ws on 16/1/18.
//  Copyright © 2016年 ws. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableData;

@property (nonatomic, strong) UIView *snapshot;

@property (nonatomic, strong) NSIndexPath *souceIndexPath;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableData = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    
    [self setUpTableView];
    
    [self setUpLongPress];
    
    self.snapshot = nil;
}


- (void)setUpTableView{

    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView;
    });
}

- (void)setUpLongPress{
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.tableView addGestureRecognizer:longPress];
}


- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *IndexPath =[self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:IndexPath];

    
    switch (longPress.state) {
            
        case UIGestureRecognizerStateBegan:{
            
            self.souceIndexPath = IndexPath;
            self.snapshot = [self customSnapshotFromView:cell];
            

            __block CGPoint center = cell.center;
            self.snapshot.center = center;
            self.snapshot.alpha = 1;
            [self.tableView addSubview:self.snapshot];
            [UIView animateWithDuration:0.25 animations:^{
                
                // Offset for gesture location.
                center.y = location.y;
                self.snapshot.center = center;
                self.snapshot.transform = CGAffineTransformMakeScale(1, 1);
                self.snapshot.alpha = 0.9;
                
                // Black out.
                cell.backgroundColor = [UIColor orangeColor];
            } completion:nil];
            
            

        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            CGPoint center = self.snapshot.center;
            center.y = location.y;
            
            self.snapshot.center = center;
            

            if (self.souceIndexPath != IndexPath) {
                NSLog(@"%ld------%ld",(long)IndexPath.row,(long)self.souceIndexPath.row);
                
                [self.tableData exchangeObjectAtIndex:IndexPath.row withObjectAtIndex:self.souceIndexPath.row];
                [self.tableView moveRowAtIndexPath:self.souceIndexPath toIndexPath:IndexPath];
                
                self.souceIndexPath = IndexPath;
            }
            
        }

            break;
            
            
        default:{
            
            [UIView animateWithDuration:0.5 animations:^{

                self.snapshot.center = cell.center;
            }completion:^(BOOL finished) {
                [self.snapshot removeFromSuperview];
                cell.backgroundColor = [UIColor whiteColor];
            }];
            
            
        }
            
            
            
            break;
    }
    
    
    
}

- (UIView *)customSnapshotFromView:(UIView *)fromView{
    
    UIView *snapshot = [fromView snapshotViewAfterScreenUpdates:true];
    
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


#pragma mark - tableView的数据源和代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tableData.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.tableData[indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
