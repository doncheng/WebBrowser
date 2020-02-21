//
//  HistorySQLiteManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ZWSQLiteManager.h"

typedef void(^HistorySQLiteDeleteCompletion)(BOOL success);

@interface HistoryItemModel : NSObject

@property (nonatomic, copy) NSString *hourMinute;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *time;

+ (HistoryItemModel *)historyItemWithHourMinute:(NSString *)hourMinute url:(NSString *)url title:(NSString *)title iconUrl:(NSString *)iconUrl time:(NSString *)time;

@end

typedef void(^HistoryCompletionHandler)(NSMutableArray<HistoryItemModel *> *);
typedef void(^HistoryTodayYesterdayCompletionHandler)(NSMutableArray<HistoryItemModel *> *today,NSMutableArray<HistoryItemModel *> *yesterday);


@interface KeywordItemModel : NSObject

@property (nonatomic, copy) NSString *hourMinute;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *time;

+ (KeywordItemModel *)keywordItemWithHourMinute:(NSString *)hourMinute title:(NSString *)title time:(NSString *)time;

@end
typedef void(^KeywordsCompletionHandler)(NSMutableArray<KeywordItemModel *> *);

@interface HistorySQLiteManager : ZWSQLiteManager

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HistorySQLiteManager)
- (void)insertOrUpdateHistoryWithURL:(NSString *)url title:(NSString *)title;
- (void)getHistoryDataByLimit:(NSInteger)limit offset:(NSInteger)offset handler:(HistoryCompletionHandler)handler;
- (void)getLastHistoryDataByLimit:(NSInteger)limit handler:(HistoryCompletionHandler)handler;
- (void)getTodayAndYesterdayHistoryDataWithHandler:(HistoryTodayYesterdayCompletionHandler)handler;
- (void)deleteHistoryRecordWithModel:(HistoryItemModel *)model completion:(HistorySQLiteDeleteCompletion)completion;
- (void)deleteAllHistoryRecords;

- (void)insertOrUpdateKeywordWithTitle:(NSString *)title;
- (void)updateIconUrlWithIconUrl:(NSString *)iconUrl url:(NSString *)url;
- (void)getKeywordsDataByLimit:(NSInteger)limit offset:(NSInteger)offset handler:(KeywordsCompletionHandler)handler;
@end
