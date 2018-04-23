/* Copyright 2018 Mozilla
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of the
 * License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License. */

import Foundation
import MentatStore

class Query: OptionalRustObject {

    func bind(varName: String, toLong value: Int64) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_long(r, varName, value)
        return self
    }

    func bind(varName: String, toReference value: Int64) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_ref(r, varName, value)
        return self
    }

    func bind(varName: String, toReference value: String) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_ref_kw(r, varName, value)
        return self
    }

    func bind(varName: String, toKeyword value: String) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_kw(r, varName, value)
        return self
    }

    func bind(varName: String, toBoolean value: Bool) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_boolean(r, varName, value ? 1 : 0)
        return self
    }

    func bind(varName: String, toDouble value: Double) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_double(r, varName, value)
        return self
    }

    func bind(varName: String, toDate value: Date) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_timestamp(r, varName, value.toMicroseconds())
        return self
    }

    func bind(varName: String, toString value: String) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        query_builder_bind_string(r, varName, value)
        return self
    }

    func bind(varName: String, toUuid value: UUID) throws -> Query {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }
        var rawUuid = value.uuid
        withUnsafePointer(to: &rawUuid) { uuidPtr in
            query_builder_bind_uuid(r, varName, uuidPtr)
        }
        return self
    }

    func run(callback: @escaping (RelResult?) -> Void) throws {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }

        let result = query_builder_execute(r)
        self.raw = nil

        if let err = result.pointee.err {
            let message = String(cString: err)
            throw QueryError.executionFailed(message: message)
        }
        guard let results = result.pointee.ok else {
            callback(nil)
            return
        }
        callback(RelResult(raw: results))
    }

    func runScalar(callback: @escaping (TypedValue?) -> Void) throws {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }

        let result = query_builder_execute_scalar(r)
        self.raw = nil

        if let err = result.pointee.err {
            let message = String(cString: err)
            throw QueryError.executionFailed(message: message)
        }
        guard let results = result.pointee.ok else {
            callback(nil)
            return
        }
        callback(TypedValue(raw: OpaquePointer(results)))
    }

    func runColl(callback: @escaping (ColResult?) -> Void) throws {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }

        let result = query_builder_execute_coll(r)
        self.raw = nil

        if let err = result.pointee.err {
            let message = String(cString: err)
             throw QueryError.executionFailed(message: message)
        }
        guard let results = result.pointee.ok else {
            callback(nil)
            return
        }
        callback(ColResult(raw: results))
    }

    func runTuple(callback: @escaping (TupleResult?) -> Void) throws {
        guard let r = self.raw else {
            throw QueryError.builderConsumed
        }

        let result = query_builder_execute_tuple(r)
        self.raw = nil

        if let err = result.pointee.err {
            let message = String(cString: err)
            throw QueryError.executionFailed(message: message)
        }
        guard let results = result.pointee.ok else {
            callback(nil)
            return
        }
        callback(TupleResult(raw: OpaquePointer(results)))
    }

    override func cleanup(pointer: OpaquePointer) {
        query_builder_destroy(pointer)
    }
}
