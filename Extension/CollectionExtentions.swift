//
//  CollectionExtentions.swift
//  PrivateKitchen
//
//  Created by 林祐正 on 2021/12/9.
//

import Foundation
import SwiftUI

// This is taken from the Release Notes, with a typo correction, marked below
struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)
    
    let base: Base
    
    var startIndex: Index { base.startIndex }
    
    // corrected typo: base.endIndex, instead of base.startIndex
    var endIndex: Index { base.endIndex }
    
    func index(after i: Index) -> Index {
        base.index(after: i)
    }
    
    func index(before i: Index) -> Index {
        base.index(before: i)
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }
    
    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

extension Array {
    func mapToSet<T: Hashable>(_ transform: (Element) -> T) -> Set<T> {
        Set(self.map(transform))
    }
}
