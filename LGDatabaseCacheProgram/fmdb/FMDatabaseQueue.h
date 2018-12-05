//
//  FMDatabaseQueue.h
//  fmdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/** To perform queries and updates on multiple threads, you'll want to use `FMDatabaseQueue`.
(要在多个线程上执行查询和更新，您需要使用`FMDatabaseQueue`。)
 Using a single instance of `<FMDatabase>` from multiple threads at once is a bad idea.  It has always been OK to make a `<FMDatabase>` object *per thread*.  Just don't share a single instance across threads, and definitely not across multiple threads at the same time.
(一次使用多个线程的单个“<FMDatabase>”实例是个坏主意。 每个线程*都可以创建一个`<FMDatabase>`对象*。 只是不要跨线程共享单个实例，并且绝对不能同时跨多个线程。)
 Instead, use `FMDatabaseQueue`. Here's how to use it:
(相反，使用`FMDatabaseQueue`。 以下是如何使用它：)
 First, make your queue.

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:aPath];

 Then use it like so:

    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:1]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:2]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:3]];

        FMResultSet *rs = [db executeQuery:@"select * from foo"];
        while ([rs next]) {
            //…
        }
    }];

 An easy way to wrap things up in a transaction can be done like this:
(在事务中包装事物的简单方法可以这样做：)
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:1]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:2]];
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:3]];

        if (whoopsSomethingWrongHappened) {
            *rollback = YES;
            return;
        }
        // etc…
        [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:4]];
    }];

 `FMDatabaseQueue` will run the blocks on a serialized[ˈsɪəri:əˌlaɪzd] queue (hence the name of the class).  So if you call `FMDatabaseQueue`'s methods from multiple[ˈməltəpəl] threads at the same time, they will be executed [ˈeksikju:tid] in the order they are received.  This way queries and updates won't step on each other's toes, and every one is happy.
(FMDatabaseQueue`将在序列化队列上运行块（因此是类的名称）。 因此，如果您同时从多个线程调用`FMDatabaseQueue`的方法，它们将按接收顺序执行。 这种方式查询和更新不会踩到彼此的脚趾，每个人都很高兴。)
 ### See also

 - `<FMDatabase>`

 @warning Do not instantiate a single `<FMDatabase>` object and use it across multiple threads. Use `FMDatabaseQueue` instead.
 (不要实例化单个`<FMDatabase>`对象并在多个线程中使用它。 请改用“FMDatabaseQueue”。)
 @warning The calls to `FMDatabaseQueue`'s methods are blocking.  So even though you are passing along blocks, they will **not** be run on another thread.
(对“FMDatabaseQueue”方法的调用是阻塞的。 所以，即使你传递的是块，它们也不会在另一个线程上运行。)
 */

@interface FMDatabaseQueue : NSObject
/** Path of database */

@property (atomic, retain, nullable) NSString *path;

/** Open flags */

@property (atomic, readonly) int openFlags;

/**  Custom virtual file system name */

@property (atomic, copy, nullable) NSString *vfsName;

///----------------------------------------------------
/// @name Initialization, opening, and closing of queue
///----------------------------------------------------

/** Create queue using path.
 
 @param aPath The file path of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

+ (nullable instancetype)databaseQueueWithPath:(NSString * _Nullable)aPath;

/** Create queue using file URL.
 
 @param url The file `NSURL` of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

+ (nullable instancetype)databaseQueueWithURL:(NSURL * _Nullable)url;

/** Create queue using path and specified flags.
 
 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */
+ (nullable instancetype)databaseQueueWithPath:(NSString * _Nullable)aPath flags:(int)openFlags;

/** Create queue using file URL and specified flags.
 
 @param url The file `NSURL` of the database.
 @param openFlags Flags passed to the openWithFlags method of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */
+ (nullable instancetype)databaseQueueWithURL:(NSURL * _Nullable)url flags:(int)openFlags;

/** Create queue using path.
 
 @param aPath The file path of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithPath:(NSString * _Nullable)aPath;

/** Create queue using file URL.
 
 @param url The file `NSURL of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithURL:(NSURL * _Nullable)url;

/** Create queue using path and specified flags.
 
 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithPath:(NSString * _Nullable)aPath flags:(int)openFlags;

/** Create queue using file URL and specified flags.
 
 @param url The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database.
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithURL:(NSURL * _Nullable)url flags:(int)openFlags;

/** Create queue using path and specified flags.
 
 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database
 @param vfsName The name of a custom virtual file system
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithPath:(NSString * _Nullable)aPath flags:(int)openFlags vfs:(NSString * _Nullable)vfsName;

/** Create queue using file URL and specified flags.
 
 @param url The file `NSURL of the database.
 @param openFlags Flags passed to the openWithFlags method of the database
 @param vfsName The name of a custom virtual file system
 
 @return The `FMDatabaseQueue` object. `nil` on error.
 */

- (nullable instancetype)initWithURL:(NSURL * _Nullable)url flags:(int)openFlags vfs:(NSString * _Nullable)vfsName;

/** Returns the Class of 'FMDatabase' subclass, that will be used to instantiate database object.
 
 Subclasses can override this method to return specified Class of 'FMDatabase' subclass.
 (返回'FMDatabase'子类，它将用于实例化数据库对象。
  
   子类可以重写此方法以返回指定的“FMDatabase”子类。)
 @return The Class of 'FMDatabase' subclass, that will be used to instantiate database object.
 */

+ (Class)databaseClass;

/** Close database used by queue. */

- (void)close;

/** Interupt pending database operation. */

- (void)interrupt;

///-----------------------------------------------
/// @name Dispatching database operations to queue
///-----------------------------------------------

/** Synchronously perform database operations on queue.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase *db))block;

/** Synchronously perform database operations on queue, using transactions.

 @param block The code to be run on the queue of `FMDatabaseQueue`
 
 @warning    Unlike SQLite's `BEGIN TRANSACTION`, this method currently performs
             an exclusive transaction, not a deferred transaction. This behavior
             is likely to change in future versions of FMDB, whereby this method
             will likely eventually adopt standard SQLite behavior and perform
             deferred transactions. If you really need exclusive tranaction, it is
             recommended that you use `inExclusiveTransaction`, instead, not only
             to make your intent explicit, but also to future-proof your code.

 */

- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations on queue, using deferred transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDeferredTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations on queue, using exclusive transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inExclusiveTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations on queue, using immediate transactions.

 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inImmediateTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

///-----------------------------------------------
/// @name Dispatching database operations to queue
///-----------------------------------------------

/** Synchronously perform database operations using save point.

 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

// NOTE: you can not nest these, since calling it will pull another database out of the pool and you'll get a deadlock.
// If you need to nest, use FMDatabase's startSavePointWithName:error: instead.
- (NSError * _Nullable)inSavePoint:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

///-----------------
/// @name Checkpoint
///-----------------

/** Performs a WAL checkpoint
 
 @param checkpointMode The checkpoint mode for sqlite3_wal_checkpoint_v2
 @param error The NSError corresponding to the error, if any.
 @return YES on success, otherwise NO.
 */
- (BOOL)checkpoint:(FMDBCheckpointMode)checkpointMode error:(NSError * _Nullable *)error;

/** Performs a WAL checkpoint
 
 @param checkpointMode The checkpoint mode for sqlite3_wal_checkpoint_v2
 @param name The db name for sqlite3_wal_checkpoint_v2
 @param error The NSError corresponding to the error, if any.
 @return YES on success, otherwise NO.
 */
- (BOOL)checkpoint:(FMDBCheckpointMode)checkpointMode name:(NSString * _Nullable)name error:(NSError * _Nullable *)error;

/** Performs a WAL checkpoint
 
 @param checkpointMode The checkpoint mode for sqlite3_wal_checkpoint_v2
 @param name The db name for sqlite3_wal_checkpoint_v2
 @param error The NSError corresponding to the error, if any.
 @param logFrameCount If not NULL, then this is set to the total number of frames in the log file or to -1 if the checkpoint could not run because of an error or because the database is not in WAL mode.
 @param checkpointCount If not NULL, then this is set to the total number of checkpointed frames in the log file (including any that were already checkpointed before the function was called) or to -1 if the checkpoint could not run due to an error or because the database is not in WAL mode.
 @return YES on success, otherwise NO.
 */
- (BOOL)checkpoint:(FMDBCheckpointMode)checkpointMode name:(NSString * _Nullable)name logFrameCount:(int * _Nullable)logFrameCount checkpointCount:(int * _Nullable)checkpointCount error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
