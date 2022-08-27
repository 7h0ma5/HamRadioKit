//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 05.08.22.
//

import Foundation

public class RangeTree<I, T> where I: Comparable {
    private var node: (
        key: I,
        value: T
    )?

    private var children: (
        left: RangeTree<I, T>?,
        right: RangeTree<I, T>?
    )

    public init() {
        node = nil
        children.left = nil
        children.right = nil
    }

    init(key: I, value: T) {
        self.node = (
            key: key,
            value: value
        )
        children.left = nil
        children.right = nil
    }

    init(buildWith items: [T], key: KeyPath<T, I>) {
        self.insert(items: items[...], key: key)
        assert(self.count == items.count)
    }

    func insert(items: ArraySlice<T>, key: KeyPath<T, I>) {
        if items.count == 0 {
            return
        }
        else if items.count == 1, let item = items.first {
            self.insert(key: item[keyPath: key], value: item)
        }
        else {
            let mid = (items.startIndex + items.endIndex)/2
            self.insert(key: items[mid][keyPath: key], value: items[mid])
            self.insert(items: items[items.startIndex..<mid], key: key)
            self.insert(items: items[(mid+1)..<items.endIndex], key: key)
        }
    }

    public func insert(key: I, value: T) {
        if let node = self.node {
            if key <= node.key {
                if let leftChild = children.left {
                    leftChild.insert(key: key, value: value)
                }
                else {
                    children.left = .init(key: key, value: value)
                }
            }
            else {
                if let rightChild = children.right {
                    rightChild.insert(key: key, value: value)
                }
                else {
                    children.right = .init(key: key, value: value)
                }
            }
        }
        else {
            self.node = (
                key: key,
                value: value
            )
            return
        }
    }

    public func search(range: ClosedRange<I>) -> [T] {
        guard let node = self.node else {
            return []
        }

        var result: [T] = []

        result.append(contentsOf: children.left?.search(range: range) ?? [])

        if node.key >= range.lowerBound && node.key <= range.upperBound {
            result.append(node.value)
        }

        if range.upperBound < node.key {
            return result
        }

        result.append(contentsOf: children.right?.search(range: range) ?? [])

        return result
    }

    public var count: UInt {
        (node != nil ? 1 : 0) +
            (children.left?.count ?? 0) +
            (children.right?.count ?? 0)
    }
}
