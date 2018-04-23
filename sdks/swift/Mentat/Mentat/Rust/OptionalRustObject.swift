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

class OptionalRustObject: Destroyable {
    var raw: OpaquePointer?
    lazy var uniqueId: ObjectIdentifier = {
         ObjectIdentifier(self)
    }()

    init(raw: UnsafeMutableRawPointer) {
        self.raw = OpaquePointer(raw)
    }

    init(raw: OpaquePointer?) {
        self.raw = raw
    }

    func intoRaw() -> OpaquePointer? {
        return self.raw
    }

    deinit {
        guard let raw = self.raw else { return }
        self.cleanup(pointer: raw)
    }

    func validPointer() throws -> OpaquePointer {
        guard let r = self.raw else {
            throw MentatError(message: "In Progress Consumed")
        }

        return r
    }

    func cleanup(pointer: OpaquePointer) {
        fatalError("\(cleanup) is not implemented.")
    }
}

