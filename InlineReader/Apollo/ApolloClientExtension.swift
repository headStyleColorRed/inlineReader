//
//  ApolloClientExtension.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 18/12/24.
//

import Apollo
import ApolloAPI
import Foundation

extension ApolloClient {
    public func asyncFetch<Query: GraphQLQuery>(query: Query,
                                                cachePolicy: CachePolicy = .default,
                                                contextIdentifier: UUID? = nil,
                                                context: RequestContext? = nil,
                                                queue: DispatchQueue = .main)
    async throws -> GraphQLResult<Query.Data> {

        // Return cache data en fetch cache policy won't work with the async/await version of this function, you need
        // to use the regular version with the completion handler instead. This limitation exists because with that
        // cache policy, the completionHandler is called twice (first with cache and second with the fetch), which is
        // not allowed in an async function.
        var cachePolicy = cachePolicy
        if cachePolicy == .returnCacheDataAndFetch {
            assertionFailure("Cache policy returnCacheDataAndFetch is not allowed in asyncFetch")
            cachePolicy = .default
        }

        let cancelState = CheckedCancellationState.makeState()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = Network.shared.apollo.fetch(
                    query: query,
                    cachePolicy: cachePolicy,
                    contextIdentifier: contextIdentifier,
                    context: context,
                    queue: queue
                ) { result in
                    switch result {
                    case .success(let graphQLResult):
                        continuation.resume(returning: graphQLResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                CheckedCancellationState.activate(state: cancelState, task: task)
            }

        } onCancel: {
            CheckedCancellationState.cancel(state: cancelState)
        }
    }

    @discardableResult
    public func asyncPerform<Mutation: GraphQLMutation>(mutation: Mutation,
                                                        publishResultToStore: Bool = true,
                                                        contextIdentifier: UUID? = nil,
                                                        context: RequestContext? = nil,
                                                        queue: DispatchQueue = .main)
    async throws -> GraphQLResult<Mutation.Data> {
        let cancelState = CheckedCancellationState.makeState()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = Network.shared.apollo.perform(
                    mutation: mutation,
                    publishResultToStore: publishResultToStore,
                    contextIdentifier: contextIdentifier,
                    context: context,
                    queue: queue
                ) { result in
                    switch result {
                    case .success(let graphQLResult):
                        continuation.resume(returning: graphQLResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                CheckedCancellationState.activate(state: cancelState, task: task)
            }

        } onCancel: {
            CheckedCancellationState.cancel(state: cancelState)
        }
    }

    public func asyncUpload<Operation: GraphQLOperation>(operation: Operation,
                                                         files: [GraphQLFile],
                                                         queue: DispatchQueue = .main)
    async throws -> GraphQLResult<Operation.Data> {
        let cancelState = CheckedCancellationState.makeState()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = Network.shared.apollo.upload(operation: operation,
                                                        files: files,
                                                        queue: queue
                ) { result in
                    switch result {
                    case .success(let graphQLResult):
                        continuation.resume(returning: graphQLResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                CheckedCancellationState.activate(state: cancelState, task: task)
            }

        } onCancel: {
            CheckedCancellationState.cancel(state: cancelState)
        }
    }
}

// Based on how Apple themselves backports URLSession.data async/await
// (/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/
// System/Library/Frameworks/Foundation.framework/Modules/Foundation.swiftmodule/arm64e-apple-ios.swiftinterface).
// https://forums.swift.org/t/how-to-use-withtaskcancellationhandler-properly/54341/43
struct CheckedCancellationState {
    public static func makeState() -> Swift.ManagedBuffer<(isCancelled: Swift.Bool,
                                                           task: Cancellable?), Darwin.os_unfair_lock> {
        ManagedBuffer<(isCancelled: Bool, task: Cancellable?), os_unfair_lock>.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { $0.initialize(to: os_unfair_lock()) }
            return (isCancelled: false, task: nil)
        }
    }
    public static func cancel(state: Swift.ManagedBuffer<(isCancelled: Swift.Bool,
                                                          task: Cancellable?), Darwin.os_unfair_lock>) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            let task = state.pointee.task
            state.pointee = (isCancelled: true, task: nil)
            os_unfair_lock_unlock(lock)
            task?.cancel()
        }
    }
    public static func activate(state: Swift.ManagedBuffer<(isCancelled: Swift.Bool,
                                                            task: Cancellable?), Darwin.os_unfair_lock>,
                                task: Cancellable) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            if state.pointee.task != nil {
                fatalError("Cannot activate twice")
            }
            if state.pointee.isCancelled {
                os_unfair_lock_unlock(lock)
                task.cancel()
            } else {
                state.pointee = (isCancelled: false, task: task)
                os_unfair_lock_unlock(lock)
            }
        }
    }
}
