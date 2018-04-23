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

class RelResult: OptionalRustObject {
    private func getRaw() throws -> OpaquePointer {
        guard let r = self.raw else {
            throw QueryResultError.resultsConsumed
        }
        return r
    }

    func row(index: Int32) throws -> TupleResult? {
        guard let row = row_at_index(try self.getRaw(), index) else {
            return nil
        }
        return TupleResult(raw: row)
    }

    override func cleanup(pointer: OpaquePointer) {
        destroy(UnsafeMutableRawPointer(pointer))
    }
}

class RelResultIterator: OptionalRustObject, IteratorProtocol  {
    typealias Element = TupleResult

    init(iter: OpaquePointer?) {
        super.init(raw: iter)
    }

    func next() -> Element? {
        guard let iter = self.raw,
            let rowPtr = rows_iter_next(iter) else {
            return nil
        }
        return TupleResult(raw: rowPtr)
    }

    override func cleanup(pointer: OpaquePointer) {
        typed_value_result_set_iter_destroy(pointer)
    }
}

extension RelResult: Sequence {
    func makeIterator() -> RelResultIterator {
        do {
            let rowIter = rows_iter(try self.getRaw())
            self.raw = nil
            return RelResultIterator(iter: rowIter)
        } catch {
            return RelResultIterator(iter: nil)
        }
    }
}
