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

import com.sun.jna.Memory;
import com.sun.jna.Pointer;

public class Mentat extends RustObject {

    static {
        System.loadLibrary("mentat_ffi");
    }

    public Mentat(String dbPath) {
        this.rawPointer = JNA.INSTANCE.store_open(dbPath);
    }

    public Mentat() {
        this.rawPointer = JNA.INSTANCE.store_open("");
    }

    public Mentat(Pointer rawPointer) { this.rawPointer = rawPointer; }

    public TxReport transact(String transaction) {
        RustResult result = JNA.INSTANCE.store_transact(this.rawPointer, transaction);
        if (result.isFailure()) {
            Log.i("Mentat", result.err);
            return null;
        }

        if (result.isSuccess()) {
            return new TxReport(result.ok);
        } else {
            return null;
        }
    }

    public long entIdForAttribute(String attribute) {
        return JNA.INSTANCE.store_entid_for_attribute(this.rawPointer, attribute);
    }

    public RustResult sync() {
        return JNA.INSTANCE.store_sync(rawPointer, "00000000-0000-0000-0000-000000000117", "http://mentat.dev.lcip.org/mentatsync/0.1");
    }

    public Query query(String query) {
        return new Query(JNA.INSTANCE.store_query(this.rawPointer, query));
    }

    public TypedValue valueForAttributeOfEntity(String attribute, long entid) {
        RustResult result = JNA.INSTANCE.store_value_for_attribute(this.rawPointer, entid, attribute);

        if (result.isSuccess()) {
            return new TypedValue(result.ok);
        }

        if (result.isFailure()) {
            Log.i("Mentat", result.err);
        }

        return null;
    }

    public void registerObserver(String key, String[] attributes, TxObserverCallback callback) {
        // turn string array into int array
        long[] attrEntids = new long[attributes.length];
        for(int i = 0; i < attributes.length; i++) {
            attrEntids[i] = JNA.INSTANCE.store_entid_for_attribute(this.rawPointer, attributes[i]);
        }
        Log.i("Mentat", "Registering observer {" + key + "} for attributes:");
        for (int i = 0; i < attrEntids.length; i++) {
            Log.i("Mentat", "entid: " + attrEntids[i]);
        }
        final Pointer entidsNativeArray = new Memory(8 * attrEntids.length);
        entidsNativeArray.write(0, attrEntids, 0, attrEntids.length);
        JNA.INSTANCE.store_register_observer(rawPointer, key, entidsNativeArray, attrEntids.length, callback);
    }

    public void unregisterObserver(String key) {
        JNA.INSTANCE.store_unregister_observer(rawPointer, key);
    }

    @Override
    public void close() {
        Log.i("Mentat", "close");
        if (this.rawPointer != null) {
            JNA.INSTANCE.store_destroy(this.rawPointer);
        }
    }
}
