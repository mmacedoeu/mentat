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

protocol Observing {
    // define functions for store observation
    func transactionDidOccur(key: String, reports: [TxChange])
}

protocol Observable {
    func register(key: String, observer: Observing, attributes: [String])
    func unregister(key: String)
}

class Mentat: RustObject {
    fileprivate static var observers = [String: Observing]()

    required override init(raw: OpaquePointer) {
        super.init(raw: raw)
    }

    convenience init(storeURI: String = "") {
        self.init(raw: store_open(storeURI))
    }

    func transact(transaction: String) throws -> TxReport {
        let result = store_transact(self.raw, transaction).pointee
        return TxReport(raw: try result.unwrap())
    }

    func beginTransaction() throws -> InProgress {
        let result = store_begin_transaction(self.raw).pointee;
        return InProgress(raw: try result.unwrap())
    }

    func entidForAttribute(attribute: String) -> Int64 {
        return Int64(store_entid_for_attribute(self.raw, attribute))
    }

    func query(query: String) -> Query {
        return Query(raw: store_query(self.raw, query))
    }

    func value(forAttribute attribute: String, ofEntity entid: Int64) throws -> TypedValue? {
        let result = store_value_for_attribute(self.raw, entid, attribute).pointee
        return TypedValue(raw: try result.unwrap())
    }

    override func cleanup(pointer: OpaquePointer) {
        store_destroy(pointer)
    }
}

extension Mentat: Observable {
    func register(key: String, observer: Observing, attributes: [String]) {
        let attrEntIds = attributes.map({ (kw) -> Int64 in
            let entid = Int64(self.entidForAttribute(attribute: kw));
            return entid
        })

        let ptr = UnsafeMutablePointer<Int64>.allocate(capacity: attrEntIds.count)
        let entidPointer = UnsafeMutableBufferPointer(start: ptr, count: attrEntIds.count)
        var _ = entidPointer.initialize(from: attrEntIds)

        guard let firstElement = entidPointer.baseAddress else {
            return
        }
        Mentat.observers[key] = observer
        store_register_observer(self.raw, key, firstElement, Int64(attributes.count), transactionObserverCallback)

    }

    func unregister(key: String) {
        store_unregister_observer(self.raw, key)
    }
}

private func transactionObserverCallback(key: UnsafePointer<CChar>, reports: UnsafePointer<TxChangeList>) {
    // needs to be done in the same thread as the calling thread otherwise the TxReportList might be released before
    // we can reference it.
    let key = String(cString: key)
    guard let observer = Mentat.observers[key] else { return }

//    let len = Int(reports.pointee.len)
//    var txReports = [TxReport]()
//    for i in 0..<len {
//        guard let report = tx_report_list_entry_at(reports, i)?.pointee else { continue }
//        txReports.append(TxReport(raw: report))
//    }
    DispatchQueue.global(qos: .background).async {
        observer.transactionDidOccur(key: key, reports: [TxChange]())
    }
}
