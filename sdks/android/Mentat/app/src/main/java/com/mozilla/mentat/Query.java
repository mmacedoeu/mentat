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

import java.nio.ByteBuffer;
import java.util.Date;
import java.util.UUID;

public class Query extends RustObject {

    public Query(Pointer pointer) {
        this.rawPointer = pointer;
    }

    Query bindLong(String varName, long value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_long(this.rawPointer, varName, value);
        return this;
    }

    Query bindEntidReference(String varName, long value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_ref(this.rawPointer, varName, value);
        return this;
    }

    Query bindKeywordReference(String varName, String value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_ref_kw(this.rawPointer, varName, value);
        return this;
    }

    Query bindKeyword(String varName, String value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_kw(this.rawPointer, varName, value);
        return this;
    }

    Query bindBoolean(String varName, boolean value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_boolean(this.rawPointer, varName, value ? 1 : 0);
        return this;
    }

    Query bindDouble(String varName, double value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_double(this.rawPointer, varName, value);
        return this;
    }

    Query bindDate(String varName, Date value) {
        this.validate();
        long timestamp = value.getTime() * 1000;
        JNA.INSTANCE.query_builder_bind_timestamp(this.rawPointer, varName, timestamp);
        return this;
    }

    Query bindString(String varName, String value) {
        this.validate();
        JNA.INSTANCE.query_builder_bind_string(this.rawPointer, varName, value);
        return this;
    }

    Query bindUUID(String varName, UUID value) {
        this.validate();
        ByteBuffer bb = ByteBuffer.wrap(new byte[16]);
        bb.putLong(value.getMostSignificantBits());
        bb.putLong(value.getLeastSignificantBits());
        byte[] bytes = bb.array();
        final Pointer bytesNativeArray = new Memory(bytes.length);
        bytesNativeArray.write(0, bytes, 0, bytes.length);
        JNA.INSTANCE.query_builder_bind_uuid(this.rawPointer, varName, bytesNativeArray);
        return this;
    }

    void run(final RelResultHandler handler) {
        this.validate();
        RustResult result = JNA.INSTANCE.query_builder_execute(rawPointer);
        rawPointer = null;

        if (result.isFailure()) {
            Log.e("Query", result.err);
            return;
        }
        handler.handleRows(new RelResult(result.ok));
    }

    void runScalar(final ScalarResultHandler handler) {
        this.validate();
        RustResult result = JNA.INSTANCE.query_builder_execute_scalar(rawPointer);
        rawPointer = null;

        if (result.isFailure()) {
            Log.e("Query", result.err);
            return;
        }

        if (result.isSuccess()) {
            handler.handleValue(new TypedValue(result.ok));
        } else {
            handler.handleValue(null);
        }
    }

    void runColl(final CollResultHandler handler) {
        this.validate();
        RustResult result = JNA.INSTANCE.query_builder_execute_coll(rawPointer);
        rawPointer = null;

        if (result.isFailure()) {
            Log.e("Query", result.err);
            return;
        }
        handler.handleList(new CollResult(result.ok));
    }

    void runTuple(final TupleResultHandler handler) {
        this.validate();
        RustResult result = JNA.INSTANCE.query_builder_execute_tuple(rawPointer);
        rawPointer = null;

        if (result.isFailure()) {
            Log.e("Query", result.err);
            return;
        }

        if (result.isSuccess()) {
            handler.handleRow(new TupleResult(result.ok));
        } else {
            handler.handleRow(null);
        }
    }

    @Override
    public void close() {
        Log.i("Query", "close");

        if (this.rawPointer == null) {
            return;
        }
        JNA.INSTANCE.query_builder_destroy(this.rawPointer);
    }
}
