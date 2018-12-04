//
//  NS_ASSUME_NONNULL_BEGIN#NS_ASSUME_NONNULL_END.m
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/12/4.
//  Copyright © 2018年 TP. All rights reserved.
//

/**
 NS_ASSUME_NONNULL_BEGIN
 NS_ASSUME_NONNULL_END
 
 我们都知道在swift中，可以使用!和?来表示一个对象是optional的还是non-optional，如view?和view!。而在 Objective-C中则没有这一区分，view既可表示这个对象是optional，也可表示是non-optional。
 这样就会造成一个问题：在 Swift与Objective-C混编时，Swift编译器并不知道一个Objective-C对象到底是optional还是non-optional，因此这种情况下编译器会隐式地将Objective-C的对象当成是non-optional。
 为了解决这个问题，苹果在Xcode 6.3引入了一个Objective-C的新特性：nullability annotations。这一新特性的核心是两个新的类型注释： __nullable 和 __nonnull 。从字面上我们可以猜到，__nullable表示对象可以是NULL或nil，而__nonnull表示对象不应该为空。当我们不遵循这一规则时，编译器就会给出警告。
 如果需要每个属性或每个方法都去指定nonnull和nullable，是一件非常繁琐的事。苹果为了减轻我们的工作量，专门提供了两个宏：NS_ASSUME_NONNULL_BEGIN，  NS_ASSUME_NONNULL_END。在这两个宏之间的代码，所有简单指针对象都被假定为nonnull，因此我们只需要去指定那些nullable的指针。
     {
         NS_ASSUME_NONNULL_BEGIN
         @interface TestObject : NSObject
 
         @property (nonatomic, strong) NSString *testString;
         @property (nonatomic) BOOL isRight;
 
         @end
         NS_ASSUME_NONNULL_END
     }
 不过，为了安全起见，苹果还制定了几条规则：
 typedef定义的类型的nullability特性通常依赖于上下文，即使是在Audited Regions中，也不能假定它为nonnull。
 复杂的指针类型(如id *)必须显示去指定是non null还是nullable。例如，指定一个指向nullable对象的nonnulla指针，可以使用”__nullable id * __nonnull”。
 我们经常使用的NSError **通常是被假定为一个指向nullable NSError对象的nullable指针。
 
 */
