//
//  HomePageViewController.m
//  AccountManager
//
//  Created by 张祥 on 16/5/13.
//  Copyright © 2016年 张祥. All rights reserved.
//

#import "HomePageViewController.h"
#import "XLPhotoCell.h"
#import "XLLayout.h"
#import "ProgressHUD.h"
#import "DataBaseHelper.h"
#import "AccountServer.h"
#import "UIImageView+WebCache.h"
#import "Account.h"
#import "AccountDetailViewController.h"
#import <QiniuSDK.h>
#import "QiniuPutPolicy.h"

#define CellSize             CGSizeMake(60, 60)
#define CollectionViewHeight 90
#define CustomSectionSpace   50
#define TagBegin             1000
#define TitleLabelHeight     20
@interface HomePageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic)AccountServer *accountServer;
@property (strong, nonatomic)NSMutableArray *collectionViewArray;
@property (strong, nonatomic)NSMutableArray *titleLabelsArray;
@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)NSDictionary *titleDic;
@property (assign)           BOOL isReloadBaseData;

@end

@implementation HomePageViewController

#pragma life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNSNotification) name:kDataFinishNSNotification object:nil];
    
    self.navigationItem.leftBarButtonItem = nil;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setTitle:@"同步" forState:UIControlStateNormal];
    
    UIBarButtonItem *leftBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(synchronizationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = leftBarbuttonItem;
    
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton setTitle:@"刷新" forState:UIControlStateNormal];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    self.isReloadBaseData = NO;
    
    _accountServer = [[AccountServer alloc] init];
    
    if ([self isNeedRequestDataFromServer]) {
        [self requestAccountListData];
    } else {
        [DataBaseHelper readDataFromDataBase];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataFinishNSNotification object:nil];
}

#pragma mark - private api

- (BOOL)isNeedRequestDataFromServer {
    
    NSString * fullPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    fullPath = [fullPath stringByAppendingPathComponent:[Tools getAccount]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fullPath]) {
        return NO;
    }
    
    return YES;
}

- (void)requestAccountListData {
    
    [ProgressHUD show:@"正在请求"];
    
    [_accountServer requestAccountListData:^(id resultObject) {
        [DataBaseHelper readDataFromDataBase];
        [ProgressHUD dismiss];
        
    } fail:^(id resultObject) {
    }];
}

- (void)initCollectionViews {
    // 创建布局
    
    NSInteger count = [DataBaseHelper numberOfSections];
    
    self.collectionViewArray = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        XLLayout *layout = [[XLLayout alloc] init];
        layout.itemSize = CellSize;
        
        CGFloat collectionW = kScreenWidth;
        CGFloat collectionH = CollectionViewHeight;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CustomSectionSpace + (CollectionViewHeight + CustomSectionSpace) * i, collectionW, collectionH) collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.scrollView addSubview:collectionView];
        
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor colorWithHex:0x029eed alpha:0.5];
        [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XLPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
        collectionView.tag = TagBegin+i;
        [self.collectionViewArray addObject:collectionView];
    }
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, CustomSectionSpace + (CollectionViewHeight + CustomSectionSpace) * self.collectionViewArray.count);
    
    [self adjustCollectionViewsPoint];
}

- (void)adjustCollectionViewsPoint {
    
    for (int i = 0; i < self.collectionViewArray.count; i++) {
        UICollectionView *collectionView = self.collectionViewArray[i];
        NSInteger count = [self getRowsWith:collectionView];
        
        //10是collectionView预留的item之间的间隔
        CGFloat totalWidth = (count - 1) * (CellSize.width + 10);
        
        //左边去掉半个, 右边去掉半个, 再加上所有的间隔, 最后除以2
        collectionView.contentOffset = CGPointMake(totalWidth / 2, 0);
    }
}

- (void)removeAllCollectionViews {
    
    for (int i = 0; i < self.collectionViewArray.count; i++) {
        UICollectionView *view = self.collectionViewArray[i];
        [view removeFromSuperview];
        view = nil;
    }
    [self.collectionViewArray removeAllObjects];
}

- (void)reloadViews {
    for (UICollectionView *view in self.collectionViewArray) {
        [view reloadData];
    }
}

- (void)addTitleLabels {
    
    self.titleLabelsArray = [NSMutableArray array];
    
    for (int i = 0; i < self.collectionViewArray.count; i++) {
        UICollectionView *collectionView = self.collectionViewArray[i];
        CGRect collectionViewFrame = collectionView.frame;
        
        NSString *markStr = [DataBaseHelper titleForHeaderInSection:i];
        NSString *title = self.titleDic[markStr];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(collectionViewFrame) - TitleLabelHeight, kScreenWidth, TitleLabelHeight)];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:label];
        
        [self.titleLabelsArray addObject:label];
    }
}

- (void)removeAllTitleLabels {
    
    for (int i = 0; i < self.titleLabelsArray.count; i++) {
        UILabel *label = self.titleLabelsArray[i];
        [label removeFromSuperview];
        label = nil;
    }
    [self.titleLabelsArray removeAllObjects];
}


- (NSIndexPath *)getCustomIndexPathWith:(UICollectionView *)collectionView currentIndexPath:(NSIndexPath *)indexPath{
    NSInteger customSection = collectionView.tag - TagBegin;
    if (self.collectionViewArray.count > customSection) {
        
        UICollectionView *view = self.collectionViewArray[customSection];
        if (view == collectionView) {
            NSIndexPath *customIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:customSection];
            return customIndexPath;
        }
    }
    return nil;
}

- (NSInteger)getRowsWith:(UICollectionView *)collectionView {
    
    NSInteger customSection = collectionView.tag - 1000;
    if (self.collectionViewArray.count > customSection) {
        UICollectionView *view = self.collectionViewArray[customSection];
        if (view == collectionView) {
            NSInteger count = [DataBaseHelper numberOfRowsInSection:customSection];
            return count;
        }
    }
    return 0;
}

- (NSString *)tokenWithScope:(NSString *)scope
{
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = scope;
    return [policy makeToken:QiniuAccessKey secretKey:QiniuSecretKey];
    
}

//获取数据库路径
- (NSString *)dataBasePath {
    //1.获取document文件夹路径
    NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //2.拼接上数据库文件路径
    return [documentpath stringByAppendingPathComponent:[Tools getAccount]];
}

#pragma mark - NSNotificationCenter
- (void)handleNSNotification {
    
    if (self.isReloadBaseData) {
        self.isReloadBaseData = NO;
        return;
    }
    
    [self initCollectionViews];
    [self addTitleLabels];
    [self reloadViews];
}

#pragma event response

- (void)synchronizationAction:(UIButton *)sender {
    [ProgressHUD show:@"正在与服务器同步, 请稍后"];

    NSString *key = [NSString stringWithFormat:@"%@:%@", kSpaceName, [Tools getAccount]];
    
    NSString *token = [self tokenWithScope:key];
    
    NSString *filePath = [self dataBasePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:data key:[Tools getAccount] token:token complete:
     ^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
     {
         [ProgressHUD showSuccess:@"同步成功"];
         DLog(@"%@", info);
         DLog(@"%@", resp);
     } option:nil];
}

- (void)refreshAction:(UIButton *)sender {
    
    [self removeAllCollectionViews];
    [self removeAllTitleLabels];
    [self requestAccountListData];
    
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getRowsWith:collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSIndexPath *customIndexPath = [self getCustomIndexPathWith:collectionView currentIndexPath:indexPath];
    
    if (indexPath) {
        Account *account = [DataBaseHelper accountIndextPath:customIndexPath];
        
        if (account) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kRequestImageUrl, account.accountName]];
            
            [cell.imageView sd_setImageWithURL:url];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *customIndexPath = [self getCustomIndexPathWith:collectionView currentIndexPath:indexPath];
    if (customIndexPath) {
        DLog(@"点击的section---%ld  row---%ld",customIndexPath.section, customIndexPath.row);
        
        //通过视图控制器与视图控制器之间的桥，跳转到下一界面
        [self performSegueWithIdentifier:@"toDetail" sender:customIndexPath];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma setters and getters
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        
        [self.view addSubview:self.scrollView];
        self.scrollView.backgroundColor = [UIColor colorWithHex:0xF7EED6];
    }
    return _scrollView;
}
- (NSDictionary *)titleDic {
    if (!_titleDic) {
        self.titleDic = @{@"0":@"财务",@"1":@"工具",@"2":@"娱乐",@"3":@"学习",@"4":@"社区",@"5":@"出行",@"6":@"购物",@"7":@"团购",@"8":@"论坛"};
    }
    return _titleDic;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *customIndexPath = (NSIndexPath *)sender;
    
    //当选中Cell进入下一界面之前，需要把选中cell对应的contact对象传入下一界面
    if ([segue.identifier isEqualToString:@"toDetail"]) {
        AccountDetailViewController *detailVC = segue.destinationViewController;
        detailVC.account = [DataBaseHelper accountIndextPath:sender];
        UICollectionView *collectionView = self.collectionViewArray[customIndexPath.section];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:customIndexPath.row inSection:0];
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        XLPhotoCell *photoCell = (XLPhotoCell *)cell;
        detailVC.accountImage = photoCell.imageView.image;
        
        [detailVC editSuccess:^{
            self.isReloadBaseData = YES;
            [DataBaseHelper readDataFromDataBase];
//            [self reloadViews];
        }];
        
        DLog(@"去详情页面");
    }
}


@end
