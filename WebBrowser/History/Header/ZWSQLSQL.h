//
//  ZWSQLSQL.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#ifndef ZWSQLSQL_h
#define ZWSQLSQL_h

#pragma mark - History

#define ZW_TABLE_HISTORY              @"history"
#define ZW_TABLE_HISTORY_HOUR_MINUTE_INDEX @"history_hour_minute_index"

#define ZW_FIELD_URL                  @"url"
#define ZW_FIELD_TITLE                @"title"
#define ZW_FIELD_HOUR_MINUTE          @"hour_minute"
#define ZW_FIELD_TIME                 @"time"

#define KK_FIELD_ICON_URL                  @"icon_url"

#define KK_TABLE_KEYWORDS              @"keywords"

#define KK_FIELD_TITLE                @"title"
#define KK_FIELD_HOUR_MINUTE          @"hour_minute"
#define KK_FIELD_TIME                 @"time"

#define ZW_SQL_CREATE_HISTORY_TABLE \
    @"CREATE TABLE IF NOT EXISTS " ZW_TABLE_HISTORY @" ("    \
        ZW_FIELD_URL             @" TEXT NOT NULL, "         \
        ZW_FIELD_TITLE           @" TEXT, "                  \
        KK_FIELD_ICON_URL        @" TEXT, "                  \
        ZW_FIELD_HOUR_MINUTE     @" TEXT, "                  \
        ZW_FIELD_TIME            @" TEXT NOT NULL, "         \
        @"PRIMARY KEY(" ZW_FIELD_URL @"," ZW_FIELD_TIME @")" \
    @");"

#define ZW_SQL_CREATE_HISTORY_INDEX_TABLE               \
    @"CREATE INDEX IF NOT EXISTS "                      \
        ZW_TABLE_HISTORY_HOUR_MINUTE_INDEX @" ON "      \
        ZW_TABLE_HISTORY @"(" ZW_FIELD_HOUR_MINUTE @", " ZW_FIELD_TIME @");"

#define ZW_SQL_INSERT_OR_IGNORE_HISTORY                 \
    @"INSERT OR IGNORE INTO " ZW_TABLE_HISTORY  @" ("   \
        ZW_FIELD_URL             @", "                  \
        ZW_FIELD_TITLE           @", "                  \
        ZW_FIELD_HOUR_MINUTE     @", "                  \
        ZW_FIELD_TIME                                   \
    @") VALUES(?, ?, ?, ?);"
#define KK_SQL_UPDATE_HISTORY_ICON                \
@"UPDATE " ZW_TABLE_HISTORY  @" SET "             \
    KK_FIELD_ICON_URL           @"=? WHERE "                  \
    ZW_FIELD_URL     @"=? "
// It's not particularly efficient, but works if iterating over a
// small index, see https://www.sqlite.org/cvstrac/wiki?p=ScrollingCursor for details,
// I just don't want to optimize, sigh.
#define ZW_SQL_SELECT_HISTORY                \
    @"SELECT * FROM " ZW_TABLE_HISTORY @" ORDER BY "  \
        ZW_FIELD_TIME           @" DESC,"         \
        ZW_FIELD_HOUR_MINUTE    @" DESC "         \
    @"LIMIT ? OFFSET ?;"

#define KK_SQL_SELECT_LAST_HISTORY                \
@"SELECT * FROM (SELECT * FROM " ZW_TABLE_HISTORY @" ORDER BY " ZW_FIELD_TIME @" DESC," ZW_FIELD_HOUR_MINUTE @" DESC) GROUP BY " ZW_FIELD_URL @" ORDER BY "  \
    ZW_FIELD_TIME           @" DESC,"         \
    ZW_FIELD_HOUR_MINUTE    @" DESC "         \
@"LIMIT ?;"

#define ZW_SQL_SELECT_TODAY_YESTERDAY_HISTORY     \
    @"SELECT * FROM " ZW_TABLE_HISTORY @" "       \
        @"WHERE "     ZW_FIELD_TIME @" = ? "      \
        @"ORDER BY "  ZW_FIELD_HOUR_MINUTE @" "   \
    @"DESC;"

#define ZW_SQL_DELETE_HISTORY_RECORD     \
    @"DELETE FROM " ZW_TABLE_HISTORY @" "       \
        @"WHERE "   ZW_FIELD_URL @" = ? "       \
        @"AND "     ZW_FIELD_TIME @" = ?;"      \

#define ZW_SQL_DELETE_ALL_HISTORY_RECORD     \
    @"DELETE FROM " ZW_TABLE_HISTORY @";"

#define KK_SQL_CREATE_KEYWORDS_TABLE \
    @"CREATE TABLE IF NOT EXISTS " KK_TABLE_KEYWORDS @" ("    \
        KK_FIELD_TITLE           @" TEXT, "                  \
        KK_FIELD_HOUR_MINUTE     @" TEXT, "                  \
        KK_FIELD_TIME            @" TEXT NOT NULL, "         \
        @"PRIMARY KEY(" KK_FIELD_TITLE @"," KK_FIELD_TIME @")" \
    @");"

#define KK_SQL_INSERT_OR_IGNORE_KEYWORDS                \
    @"INSERT OR IGNORE INTO " KK_TABLE_KEYWORDS  @" ("   \
        KK_FIELD_TITLE           @", "                  \
        KK_FIELD_HOUR_MINUTE     @", "                  \
        KK_FIELD_TIME                                   \
    @") VALUES(?, ?, ?);"
#define KK_SQL_SELECT_KEYWORDS                \
@"SELECT * FROM " KK_TABLE_KEYWORDS @" ORDER BY "  \
    KK_FIELD_TIME           @" DESC,"         \
    KK_FIELD_HOUR_MINUTE    @" DESC "         \
@"LIMIT ? OFFSET ?;"


#endif /* ZWSQLSQL_h */
