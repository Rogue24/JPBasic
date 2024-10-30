//
//  JPNSCacheViewController.m
//  JPBasic_Example
//
//  Created by 周健平 on 2023/5/19.
//  Copyright © 2023 zhoujianping24@hotmail.com. All rights reserved.
//
//  参考1：https://www.jianshu.com/p/245c78aa6563
//  参考2：https://blog.csdn.net/weixin_46926959/article/details/121122830
//
//  📢 注意：
//  根据观察和推测，NSCache很可能使用了某种【变种的LRU算法】或类似的策略。
//  这是因为在实际使用中，较新的数据项往往更有可能被保留在缓存中，而较旧的数据项可能会被自动清除以释放内存。
//
//  我的结论：
//  只能说NSCache使用的淘汰策略接近LRU算法，经多次调试后就不是按照我下面写的逻辑删除的！
//
//  🌰 测试：
//  `saveOne`和`visitAndSaveOne`方法多次交替使用后就会预测错误！

#import "JPNSCacheViewController.h"

@interface JPNSCacheViewController () <NSCacheDelegate>
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, assign) NSInteger newKey;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, assign) NSInteger countLimit;
@end

@implementation JPNSCacheViewController

/**
 * `NSCache`是系统提供的一种类似于集合（`NSMutableDictionary`）的缓存，它与集合的不同如下：
 * 1. `NSCache`具有【自动删除】的功能，以减少系统占用的内存；
 * 2. `NSCache`是【线程安全】的，不需要加线程锁；
 * 3. 键对象不会像`NSMutableDictionary`中那样被复制（键不需要实现`NSCopying`协议）。
 */

/**
 * `LRU(Least Recently Used)`算法是一种常用的缓存淘汰算法，用于管理缓存中的数据项。
 * LRU算法的核心思想是基于数据的访问历史，将最近最少被使用的数据项淘汰出缓存，以便为新的数据项腾出空间。
 *
 * LRU算法维护一个缓存空间，其中包含了一定数量的数据项。
 * 每当访问或更新一个数据项时，该数据项就会被标记为最近被使用，保持在缓存中。
 * 当缓存空间已满并需要插入新的数据项时，LRU算法会淘汰最久未被使用的数据项，也就是最老的数据项。
 *
 * LRU算法的实现通常使用一个数据结构来维护数据项的顺序。
 * 常用的数据结构是链表（Linked List），通过在链表的头部插入最近被使用的数据项，并在缓存空间已满时从链表尾部移除数据项。
 * 这样，链表的头部始终是最近被使用的数据项，而尾部是最久未被使用的数据项。
 *
 * 当一个数据项被访问时，如果它已经存在于缓存中，则将其移动到链表头部。
 * 如果数据项不存在于缓存中，则将其插入链表头部，同时检查缓存是否已满，如果已满，则将链表尾部的数据项淘汰。
 *
 * 通过使用LRU算法，缓存可以更有效地利用有限的空间，将最常被访问的数据项保留在缓存中，提高缓存命中率，减少访问磁盘或网络的开销。
 */

- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        
        // 设置最大缓存数据的数量，如果超出该限制，那么内部会自动开启一个回收过程，把最先存储的数据删除
        _cache.countLimit = self.countLimit;
        
        // 设置最大的缓存成本 --- 成本：单位概念
        /*
         * 例如：以图片总像素所占的字节数作为单位
            - 那么每次存入设置的成本为：image.size.width * image.scale * image.size.height * image.scale
         * 例如：9
            - 如果每次存入设置的成本为：2，那么最多也就只能存4个 --- 2 * 4 = 8
         * 存的时候可以设置成本：
            - [self.cache setObject:view forKey:@(i) cost:2]; // cost：缓存的单位成本
         */
//        _cache.totalCostLimit = 9;
        
        _cache.delegate = self;
    }
    return _cache;
}

- (NSMutableArray *)keys {
    if (!_keys) _keys = [NSMutableArray array];
    return _keys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = JPRandomColor;
    
    self.countLimit = 10;
    
    UIButton *btn1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"check" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(check) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 120, 120, 80);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn1];
    
    UIButton *btn2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"save" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 220, 120, 80);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn2];
    
    UIButton *btn3 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"saveOne" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveOne) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 320, 120, 80);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn3];
    
    UIButton *btn4 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"visitAndSaveOne" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(visitAndSaveOne) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 420, 120, 80);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn4];
    
    UIButton *btn5 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:@"test" forState:UIControlStateNormal];
        [btn setTitleColor:JPRandomColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(bbb) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(100, 520, 120, 80);
        btn.backgroundColor = JPRandomColor;
        btn;
    });
    [self.view addSubview:btn5];
}

- (void)aaa {
    JPLog(@"aaa");
}
- (void)bbb {
    JPLog(@"bbb");
}

- (void)check {
    JPLog(@"================[check]================");
//    for (NSInteger i = (self.keys.count - 1); i < self.keys.count; i--) {
//        NSInteger key = [self.keys[i] integerValue];
//        UIView *view = [self.cache objectForKey:@(key)];
//        if (view) {
//            JPLog(@"取 %zd --- %p", key, view);
//        } else {
//            JPLog(@"取 %zd --- 空", key);
//        }
//    }
    
    [self.keys removeAllObjects];
    for (NSInteger i = 0; i < 200; i++) {
        UIView *view = [self.cache objectForKey:@(i)];
        if (view) {
            JPLog(@"取 %zd --- %p", i, view);
            [self.keys insertObject:@(i) atIndex:0];
        }
    }
}

- (void)save {
    JPLog(@"================[save]================");
    [self.keys removeAllObjects];
    [self.cache removeAllObjects];
    for (NSInteger i = 0; i < self.countLimit; i++) {
        UIView *view = [UIView new];
        view.tag = i;
        
        [self.cache setObject:view forKey:@(i)];
        
        // 设置缓存的单位成本
//        [self.cache setObject:view forKey:@(i) cost:2];
        
        JPLog(@"存【%zd】--- %p", i, view);
        [self.keys insertObject:@(i) atIndex:0];
    }
    self.newKey = self.countLimit;
}

- (void)saveOne {
    JPLog(@"================[saveOne]================");
    JPLog(@"self.keys = %@", self.keys);
    NSInteger removeKey = [self.keys.lastObject integerValue];
    JPLog(@"要删除最久未被使用的view，预测是下标为【%zd】的view", removeKey);
    
    UIView *view2 = [UIView new];
    view2.tag = self.newKey;
    JPLog(@"【%zd】--- %p", self.newKey, view2);
    [self.cache setObject:view2 forKey:@(self.newKey)];
    [self.keys insertObject:@(self.newKey) atIndex:0]; // 把最近被使用的下标挪到头部
    self.newKey += 1;
}

- (void)visitAndSaveOne {
    JPLog(@"================[visitAndSaveOne]================");
    JPLog(@"self.keys = %@", self.keys);
    NSInteger key = [self.keys.lastObject integerValue];
    UIView *view1 = [self.cache objectForKey:@(key)];
    if (view1) {
        JPLog(@"原本要删除最久未被使用的view：【%zd】--- %p", key, view1);
        JPLog(@"但是我这里访问了一下，这样一来这个view就会被标记为最近被使用");
        // 把最近被使用的下标挪到头部
        [self.keys removeLastObject];
        [self.keys insertObject:@(key) atIndex:0];
        
        NSInteger removeKey = [self.keys.lastObject integerValue];
        JPLog(@"而最久未被使用的view则顺延到下一个，预测是下标为【%zd】的view", removeKey);
    }
    
    UIView *view2 = [UIView new];
    view2.tag = self.newKey;
    JPLog(@"存【%zd】--- %p", self.newKey, view2);
    [self.cache setObject:view2 forKey:@(self.newKey)];
    [self.keys insertObject:@(self.newKey) atIndex:0]; // 把最近被使用的下标挪到头部
    self.newKey += 1;
}

#pragma mark - <NSCacheDelegate>
// 内部开启回收过程的时候调用
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    // 如果是原有的obj，不会触发这里，但会刷新这个obj的存储顺序（变成最新存储的）
    // 如果是新的obj，从最先存储的那个数据开始删除：
    JPLog(@"⚠️ 内部开启了回收过程，从最久未被使用的那个数据开始删除：【%zd】--- %p", [(UIView *)obj tag], obj);
    if (self.keys.count > 0) {
        [self.keys removeObject:@([(UIView *)obj tag])];
    }
}

@end
