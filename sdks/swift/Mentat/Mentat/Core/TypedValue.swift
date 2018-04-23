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

class TypedValue: OptionalRustObject {

    var value: Any?

    var valueType: ValueType {
        return typed_value_value_type(self.raw!)
    }

    private func isConsumed() -> Bool {
        return self.raw == nil
    }

    func asLong() -> Int64 {
        defer {
            self.raw = nil
        }
        if !self.isConsumed() {
            self.value = typed_value_as_long(self.raw!)
        }
        return self.value as! Int64
    }

    func asEntid() -> Int64 {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            self.value = typed_value_as_entid(self.raw!)
        }
        return self.value as! Int64
    }

    func asKeyword() -> String {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            self.value = String(cString: typed_value_as_kw(self.raw!))
        }
        return self.value as! String
    }

    func asBool() -> Bool {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            let v = typed_value_as_boolean(self.raw!)
            self.value =  v > 0
        }
        return self.value as! Bool
    }

    func asDouble() -> Double {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            self.value = typed_value_as_double(self.raw!)
        }
        return self.value as! Double
    }

    func asDate() -> Date {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            let timestamp = typed_value_as_timestamp(self.raw!)
            self.value = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        return self.value as! Date
    }

    func asString() -> String {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            self.value = String(cString: typed_value_as_string(self.raw!))
        }
        return self.value as! String
    }

    func asUUID() -> UUID? {
        defer {
            self.raw = nil
        }

        if !self.isConsumed() {
            let bytes = typed_value_as_uuid(self.raw!).pointee
            self.value = UUID(uuid: bytes)
        }
        return self.value as! UUID?
    }

    override func cleanup(pointer: OpaquePointer) {
        typed_value_destroy(pointer)
    }
}
