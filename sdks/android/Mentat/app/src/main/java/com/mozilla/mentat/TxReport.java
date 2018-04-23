/* -*- Mode: Java; c-basic-offset: 4; tab-width: 20; indent-tabs-mode: nil; -*-
 * Copyright 2018 Mozilla
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of the
 * License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License. */

package com.mozilla.mentat;

import android.util.Log;

import com.sun.jna.Pointer;

import java.util.Date;

public class TxReport extends RustObject {

    private Long txId;
    private Date txInstant;


    public TxReport(Pointer pointer) {
        this.rawPointer = pointer;
    }

    public Long getTxId() {
        if (this.txId == null) {
            this.txId = JNA.INSTANCE.tx_report_get_entid(this.rawPointer);
        }

        return this.txId;
    }

    public Date getTxInstant() {
        if (this.txInstant == null) {
            this.txInstant = new Date(JNA.INSTANCE.tx_report_get_tx_instant(this.rawPointer));
        }
        return this.txInstant;
    }

    public Long getEntidForTempId(String tempId) {
        Pointer longPointer =  JNA.INSTANCE.tx_report_entity_for_temp_id(this.rawPointer, tempId);
        if (longPointer == null) {
            return null;
        }

        return longPointer.getLong(0);
    }

    @Override
    public void close() {
        Log.i("TxReport", "close");
        if (this.rawPointer != null) {
            JNA.INSTANCE.tx_report_destroy(this.rawPointer);
        }
    }
}
