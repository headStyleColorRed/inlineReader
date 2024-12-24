//
//  ArrayExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation

public extension Array {
    func elementIn(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }

    /// Tries to insert the `element` at the specified `index`.
    /// It returns without changes if `index` is not a valid index for `self`.
    mutating func safeInsert(_ element: Element, at index: Int) {
        guard index >= 0, index <= count else { return }
        self.insert(element, at: index)
    }

    /// Tries to insert the contents of `elements` at the specified `index`.
    /// It returns without changes if `index` is not a valid index for `self`.
    mutating func safeInsert(contentsOf elements: [Element], at index: Int) {
        guard index >= 0, index <= count else { return }
        self.insert(contentsOf: elements, at: index)
    }

    /// Tries to delete the `element` at the specified `index`.
    /// It returns without changes if `index` is not a valid index for `self`.
    mutating func safeDelete(at index: Int) {
        guard index >= 0, index <= count else { return }
        self.remove(at: index)
    }

    func firstById(of item: Element?) -> Element? where Element: Identifiable {
        first { $0.id == item?.id }
    }

    func firstIndexById(of item: Element?) -> Index? where Element: Identifiable {
        firstIndex { $0.id == item?.id }
    }
}

public extension Sequence where Iterator.Element: Identifiable {
    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element.ID> = []
        return filter { seen.insert($0.id).inserted }
    }
}

// https://gist.github.com/DougGregor/92a2e4f6e11f6d733fb5065e9d1c880f
// swiftlint:disable identifier_name
public extension Collection {
    @discardableResult
    func parallelMap<T>(
        parallelism requestedParallelism: Int? = nil,
        _ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        let defaultParallelism = 2
        let parallelism = requestedParallelism ?? defaultParallelism

        let n = count
        if n == 0 {
            return []
        }
        return try await withThrowingTaskGroup(of: (Int, T).self, returning: [T].self) { group in
            var result = [T?](repeatElement(nil, count: n))

            var i = self.startIndex
            var submitted = 0

            func submitNext() async throws {
                if i == self.endIndex { return }

                group.addTask { [submitted, i] in
                    let value = try await transform(self[i])
                    return (submitted, value)
                }
                submitted += 1
                formIndex(after: &i)
            }

            // submit first initial tasks
            for _ in 0 ..< parallelism {
                try await submitNext()
            }

            // as each task completes, submit a new task until we run out of work
            while let (index, taskResult) = try await group.next() {
                result[index] = taskResult

                try Task.checkCancellation()
                try await submitNext()
            }

            assert(result.count == n)
            return Array(result.compactMap { $0 })
        }
    }
}

public extension MutableCollection where Element: Identifiable {
    @discardableResult
    mutating func update(_ element: Element) -> Bool {
        guard let index = self.firstIndex(where: { $0.id == element.id }) else { return false }
        self[index] = element
        return true
    }
}
// swiftlint:enable identifier_name
