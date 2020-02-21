//
//  HomePageView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HomePageView.h"
#import "SearchViewController.h"
#import "BrowserViewController.h"
#import "LinkCollectionViewCell.h"
#import "HistoryTableViewController.h"
#import "BookmarkTableViewController.h"
#import "HistorySQLiteManager.h"
@interface HomePageView()
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) NSMutableArray           *firstLinkItems;
@property (nonatomic, strong) NSMutableArray           *secondLinkItems;
@end

@implementation HomePageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView{
    self.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    UIButton *searchButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        btn.layer.cornerRadius = 10;
        [btn setTitle:TEXT_FIELD_PLACEHOLDER forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self addSubview:btn];
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[btn]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        
        [btn addTarget:self action:@selector(handleSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        btn;
    });
    
    UIImageView *logoImage = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yuerenge"]];
        imageView.contentMode = UIViewContentModeBottom;
        [self addSubview:imageView];
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:K_Width]];
        
        imageView;
    });
   float height =  [UIScreen mainScreen].bounds.size.height;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[logoImage(200)]-17-[searchButton(45)]-%f-|",height/2] options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchButton,logoImage)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:logoImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:searchButton attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f]];
    
    UISwipeGestureRecognizer*recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchButtonClicked)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self addGestureRecognizer:recognizer];

    [self addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.frame = CGRectMake(30, height/2-50, K_Width-60, 240);
    self.firstLinkItems = [[NSMutableArray alloc] init];
    self.secondLinkItems = [[NSMutableArray alloc] init];
    WEAK_REF(self)
    [[HistorySQLiteManager sharedInstance] getLastHistoryDataByLimit:4 handler:^(NSMutableArray<HistoryItemModel *> *array){
        // always called in main thread
        STRONG_REF(self_)
        for (HistoryItemModel * model in array) {
            LinkModel *linkModel = [[LinkModel alloc] init];
            linkModel.title = model.title;
            linkModel.url = model.url;
            linkModel.iconUrl = model.iconUrl;
            [self_.firstLinkItems addObject:linkModel];
        }
        if (self_.firstLinkItems.count < 4) {
            for (int i=0; i<4; i++) {
                LinkModel *linkModel = [[LinkModel alloc] init];

                switch (i) {
                    case 0:
                        linkModel.title = @"百度";
                        linkModel.url = @"http://baidu.com";
                        linkModel.placeholder = @"icon_baidu";
                        break;
                    case 1:
                        linkModel.title = @"新浪网";
                        linkModel.url = @"https://sina.cn/";
                        linkModel.placeholder = @"icon_sina";
                        break;
                    case 2:
                        linkModel.title = @"Bilibili";
                        linkModel.url = @"https://m.bilibili.com/";
                        linkModel.placeholder= @"icon_bili";
                        break;
                    case 3:
                        linkModel.title = @"虎扑";
                        linkModel.url = @"https://m.hupu.com";
                        linkModel.placeholder = @"icon_hupu";
                        break;
                    default:
                        break;
                }
                [self.firstLinkItems addObject:linkModel];
            }
        }
        
    }];

    for (int i=0; i<2; i++) {
        LinkModel *linkModel = [[LinkModel alloc] init];
        linkModel.isSystem = YES;
        switch (i) {
            case 0:
                linkModel.title = @"书签";
                linkModel.placeholder = @"favorites";
                break;
             case 1:
                linkModel.title = @"历史记录";
                linkModel.placeholder = @"history";
                break;
            case 2:
                linkModel.title = @"历史记录";
                break;
            case 3:
                linkModel.title = @"历史记录";
                break;
            default:
                break;
        }
        [self.secondLinkItems addObject:linkModel];
    }
    
    
}

- (void)handleSearchButtonClicked{
    [Notifier postNotification:[NSNotification notificationWithName:kExpandHomeToolBarNotification object:nil]];
    SearchViewController *searchVC = [SearchViewController new];
    searchVC.origTextFieldString = @"";
    [[BrowserVC navigationController] pushViewController:searchVC animated:NO];
}
#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }else if (section == 1){
        return self.secondLinkItems.count;
    }
    return self.firstLinkItems.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LinkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LinkCollectionViewCell" forIndexPath:indexPath];
    CGFloat width = (K_Width - 75) / 4;
    CGFloat height = width * 16 / 9;
    if (indexPath.section == 0) {
        cell.model = self.firstLinkItems[indexPath.row];
    }else if (indexPath.section == 1){
        cell.model = self.secondLinkItems[indexPath.row];
    }
    
    UIVisualEffectView*blurEffectView = [cell.contentView viewWithTag:100];
    UIButton * moreBtn = [cell.contentView viewWithTag:101];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //CateModel *cateModel = [self.videos objectAtIndex:indexPath.row];
    switch (indexPath.section) {
        case 0:{
            LinkModel *itemModel = self.firstLinkItems[indexPath.row];
            [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[itemModel.url] key:kDelegateManagerBrowserContainerLoadURL];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    {
                        BookmarkTableViewController *bookmarkTableViewController = [[BookmarkTableViewController alloc] init];
                        
                        [BrowserVC presentViewController:[[UINavigationController alloc] initWithRootViewController:bookmarkTableViewController] animated:YES completion:^{
                            
                        }];
                    }
                    break;
                case 1:
                    {
                        HistoryTableViewController *historyTableViewController = [[HistoryTableViewController alloc] init];
                        
                        [BrowserVC presentViewController:[[UINavigationController alloc] initWithRootViewController:historyTableViewController] animated:YES completion:^{
                            
                        }];
                    }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }

}
#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat width = (K_Width - 75) / 4;
        CGFloat height = 100;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(width, height);
        layout.minimumLineSpacing = 20.0f;
        layout.minimumInteritemSpacing = 5.0f;
        layout.headerReferenceSize = CGSizeMake(0, 20);
        //layout.footerReferenceSize = CGSizeMake(5, height);
        //layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //_collectionView.showsHorizontalScrollIndicator = NO;
        //_collectionView.backgroundColor = [PublicKit colorWithHexValue:0x000000 alpha:1];
        [_collectionView registerClass:[LinkCollectionViewCell class] forCellWithReuseIdentifier:@"LinkCollectionViewCell"];

    }
    return _collectionView;
}

@end
