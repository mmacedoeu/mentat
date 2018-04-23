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

class TxReport: RustObject {

    public var txId: Int64 {
        return tx_report_get_entid(self.raw)
    }

    public var txInstant: Date {
        return Date(timeIntervalSince1970: TimeInterval(tx_report_get_tx_instant(self.raw)))
    }

    public func entidForTempId(tempId: String) -> Int64? {
        guard let entidPtr = tx_report_entity_for_temp_id(self.raw, tempId) else {
            return nil
        }
        return entidPtr.pointee
    }

    override func cleanup(pointer: OpaquePointer) {
        tx_report_destroy(pointer)
    }
}
