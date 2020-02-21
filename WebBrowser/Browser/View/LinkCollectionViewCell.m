

#import "LinkCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation KKTextAlignmentTopLabel
- (void)drawTextInRect:(CGRect)rect {
    CGRect actualRect = [self textRectForBounds:rect
                         limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}
@end
@interface LinkCollectionViewCell()

@property (nonatomic, strong) UIImageView   *coverImgView;

@property (nonatomic, strong) UIView   *colorView;

@property (nonatomic, strong) KKTextAlignmentTopLabel   *titleLabel;

@property (nonatomic, strong) UILabel   *iconLabel;

@end

@implementation LinkCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.colorView = ({
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake((CGRectGetWidth(frame)-55)/2, 0, 55, 55);
            [view.layer setCornerRadius:10.0];
            view.layer.masksToBounds = YES;
            view;
        });
        [self.contentView addSubview:self.colorView];
        self.titleLabel = ({
            KKTextAlignmentTopLabel *label = [[KKTextAlignmentTopLabel alloc] init];
            label.textColor = UIColorFromRGB(0x8A8A8D);
            label.font = [UIFont systemFontOfSize:13];
            label.frame = CGRectMake(0, 55+10, CGRectGetWidth(frame), 35);
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 2;
            label;
        });
        [self.contentView addSubview:self.titleLabel];
        
        [self.colorView addSubview:self.coverImgView];
        self.coverImgView.frame = CGRectMake((55-32)/2, (55-32)/2, 32, 32);
        
        self.iconLabel = ({
            UILabel *avatarLabel = [[UILabel alloc] initWithFrame:self.coverImgView.bounds];
             avatarLabel.font = [UIFont systemFontOfSize:18];
             avatarLabel.textColor = [UIColor whiteColor];
             avatarLabel.textAlignment = NSTextAlignmentCenter;
             avatarLabel.tag = 3;
            avatarLabel;
        });
        [self.coverImgView addSubview:self.iconLabel];

        
    }
    return self;
}

- (void)setModel:(LinkModel *)model {
    _model = model;
    //self.layer.borderColor = [UIColor grayColor].CGColor;
    CGFloat alpha, red, blue, green;
    red   = [self colorComponentFrom: model.color start: 0 length: 2];
    green = [self colorComponentFrom: model.color start: 2 length: 2];
    blue  = [self colorComponentFrom: model.color start: 4 length: 2];
    
    self.titleLabel.text = model.title;
    if (model.iconUrl == nil && model.placeholder == nil) {
        self.coverImgView.backgroundColor = [UIColor orangeColor];
        if (model.title.length > 0) {
            self.iconLabel.text = [model.title substringToIndex:1];
        }
        
    }else{
        self.coverImgView.backgroundColor = [UIColor clearColor];
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] placeholderImage:[UIImage imageNamed:model.placeholder] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error == nil) {
                self.layer.borderWidth = 0;
            }
        }];
    }
    if (model.isSystem == YES) {
        self.colorView.backgroundColor = [UIColor colorWithRed:1 green:0.5 blue:0 alpha:0.1];
    }else{
        self.colorView.backgroundColor = UIColorFromRGB(0xF1F2F3);;
    }
}

- (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
     NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
     NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
     unsigned hexComponent;
     [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
     return hexComponent / 255.0;
}

#pragma mark - 懒加载
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.clipsToBounds = YES;
        [_coverImgView.layer setCornerRadius:4.0];
        _coverImgView.layer.masksToBounds = YES;
    }
    return _coverImgView;
}

@end
