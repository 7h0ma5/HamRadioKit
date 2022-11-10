//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 04.08.22.
//

import Foundation

public class IntervalTree<I, T> where I: Comparable {
    private var node: (
        range: ClosedRange<I>,
        value: T,
        max: I
    )?

    private var children: (
        left: IntervalTree<I, T>?,
        right: IntervalTree<I, T>?
    )

    public init() {
        node = nil
        children.left = nil
        children.right = nil
    }

    init(range: ClosedRange<I>, value: T) {
        self.node = (
            range: range,
            value: value,
            max: range.upperBound
        )
        children.left = nil
        children.right = nil
    }

    init(buildWith items: [T], rangeKey: KeyPath<T, ClosedRange<I>>) {
        self.insert(items: items[...], rangeKey: rangeKey)
        assert(self.count == items.count)
    }

    func insert(items: ArraySlice<T>, rangeKey: KeyPath<T, ClosedRange<I>>) {
        if items.count == 0 {
            return
        }
        else if items.count == 1, let item = items.first {
            self.insert(range: item[keyPath: rangeKey], value: item)
        }
        else {
            let mid = (items.startIndex + items.endIndex)/2
            self.insert(range: items[mid][keyPath: rangeKey], value: items[mid])
            self.insert(items: items[items.startIndex..<mid], rangeKey: rangeKey)
            self.insert(items: items[(mid+1)..<items.endIndex], rangeKey: rangeKey)
        }
    }

    public func insert(range: ClosedRange<I>, value: T) {
        if let node = self.node {
            if range.lowerBound <= node.range.lowerBound {
                if let leftChild = children.left {
                    leftChild.insert(range: range, value: value)
                }
                else {
                    children.left = .init(range: range, value: value)
                }
            }
            else {
                if let rightChild = children.right {
                    rightChild.insert(range: range, value: value)
                }
                else {
                    children.right = .init(range: range, value: value)
                }
            }

            if node.max < range.upperBound {
                self.node?.max = range.upperBound
            }
        }
        else {
            self.node = (
                range: range,
                value: value,
                max: range.upperBound
            )
            return
        }
    }

    public func search(range: ClosedRange<I>) -> [T] {
        guard let node = self.node else {
            return []
        }

        if range.lowerBound > node.max {
            return []
        }

        var result: [T] = []

        result.append(contentsOf: children.left?.search(range: range) ?? [])

        if node.range.lowerBound <= range.upperBound && node.range.upperBound >= range.lowerBound {
            result.append(node.value)
        }

        if range.upperBound < node.range.lowerBound {
            return result
        }

        result.append(contentsOf: children.right?.search(range: range) ?? [])

        return result
    }

    public func search(point: I) -> [T] {
        guard let node = self.node else {
            return []
        }

        if point > node.max {
            return []
        }

        var result: [T] = []

        result.append(contentsOf: children.left?.search(point: point) ?? [])

        if node.range.contains(point) {
            result.append(node.value)
        }

        if point < node.range.lowerBound {
            return result
        }

        result.append(contentsOf: children.right?.search(point: point) ?? [])

        return result
    }

    public var count: UInt {
        (node != nil ? 1 : 0) +
            (children.left?.count ?? 0) +
            (children.right?.count ?? 0)
    }
}
