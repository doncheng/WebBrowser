//
//  ZWFastEnumeration.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/8/12.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZWFastEnumeration <NSFastEnumeration>

- (id)zw_enumeratedType;

@end

#define foreach(element, collection) for (typeof((collection).zw_enumeratedType) element in (collection))

@interface NSArray <ElementType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (ElementType)zw_enumeratedType;

@end

@interface NSSet <ElementType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (ElementType)zw_enumeratedType;

@end

@interface NSDictionary <KeyType, ValueType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (KeyType)zw_enumeratedType;

@end

@interface NSOrderedSet <ElementType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (ElementType)zw_enumeratedType;

@end

@interface NSPointerArray (ZWFastEnumeration) <ZWFastEnumeration>

- (void *)zw_enumeratedType;

@end

@interface NSHashTable <ElementType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (ElementType)zw_enumeratedType;

@end

@interface NSMapTable <KeyType, ValueType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (KeyType)zw_enumeratedType;

@end

@interface NSEnumerator <ElementType> (ZWFastEnumeration)
<ZWFastEnumeration>

- (ElementType)zw_enumeratedType;

@end
