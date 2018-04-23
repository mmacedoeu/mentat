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

class TupleResult: OptionalRustObject {

    func get(index: Int) -> TypedValue {
        return TypedValue(raw: value_at_index(self.raw!, Int32(index)))
    }

    func asLong(index: Int) -> Int64 {
        return value_at_index_as_long(self.raw!, Int32(index))
    }

    func asEntid(index: Int) -> Int64 {
        return value_at_index_as_entid(self.raw!, Int32(index))
    }

    func asKeyword(index: Int) -> String {
        return String(cString: value_at_index_as_kw(self.raw!, Int32(index)))
    }

    func asBool(index: Int) -> Bool {
        return value_at_index_as_boolean(self.raw!, Int32(index)) == 0 ? false : true
    }

    func asDouble(index: Int) -> Double {
        return value_at_index_as_double(self.raw!, Int32(index))
    }

    func asDate(index: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(value_at_index_as_timestamp(self.raw!, Int32(index))))
    }

    func asString(index: Int) -> String {
        return String(cString: value_at_index_as_string(self.raw!, Int32(index)))
    }

    func asUUID(index: Int) -> UUID? {
        return UUID(uuid: value_at_index_as_uuid(self.raw!, Int32(index)).pointee)
    }

    override func cleanup(pointer: OpaquePointer) {
        typed_value_list_destroy(pointer)
    }
}

class ColResult: TupleResult {
}

class ColResultIterator: OptionalRustObject, IteratorProtocol  {
    typealias Element = TypedValue

    init(iter: OpaquePointer?) {
        super.init(raw: iter)
    }

    func next() -> Element? {
        guard let iter = self.raw,
            let rowPtr = values_iter_next(iter) else {
                return nil
        }
        return TypedValue(raw: rowPtr)
    }

    override func cleanup(pointer: OpaquePointer) {
        typed_value_list_iter_destroy(pointer)
    }
}

extension ColResult: Sequence {
    func makeIterator() -> ColResultIterator {
        defer {
            self.raw = nil
        }
        guard let raw = self.raw else {
            return ColResultIterator(iter: nil)
        }
        let rowIter = values_iter(raw)
        return ColResultIterator(iter: rowIter)
    }
}
