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

import java.io.BufferedReader;
import java.nio.ByteBuffer;
import java.util.Date;
import java.util.UUID;

public class TypedValue extends RustObject {

    private Object value;

    private boolean isConsumed() {
        return this.rawPointer == null;
    }

    public TypedValue(Pointer pointer) {
        this.rawPointer = pointer;
    }

    public Long asLong() {
        if (!this.isConsumed()) {
            this.value = JNA.INSTANCE.typed_value_as_long(this.rawPointer);
            this.rawPointer = null;
        }
        return (Long)value;
    }

    public Long asEntid() {
        if (!this.isConsumed()) {
            this.value = JNA.INSTANCE.typed_value_as_entid(this.rawPointer);
            this.rawPointer = null;
        }
        return (Long)value;
    }

    public String asKeyword() {
        if (!this.isConsumed()) {
            this.value = JNA.INSTANCE.typed_value_as_kw(this.rawPointer);
            this.rawPointer = null;
        }
        return (String)value;
    }

    public Boolean asBoolean() {
        if (!this.isConsumed()) {
            long value = JNA.INSTANCE.typed_value_as_boolean(this.rawPointer);
            this.value = value == 0 ? false : true;
            this.rawPointer = null;
        }
        return (Boolean) this.value;
    }

    public Double asDouble() {
        if (!this.isConsumed()) {
            this.value = JNA.INSTANCE.typed_value_as_double(this.rawPointer);
            this.rawPointer = null;
        }
        return (Double)value;
    }

    public Date asDate() {
        if (!this.isConsumed()) {
            this.value = new Date(JNA.INSTANCE.typed_value_as_timestamp(this.rawPointer) * 1_000);
            this.rawPointer = null;
        }
        return (Date)this.value;
    }

    public String asString() {
        if (!this.isConsumed()) {
            this.value = JNA.INSTANCE.typed_value_as_string(this.rawPointer);
            this.rawPointer = null;
        }
        return (String)value;
    }

    public UUID asUUID() {
        if (!this.isConsumed()) {
            Pointer uuidPtr = JNA.INSTANCE.typed_value_as_uuid(this.rawPointer);
            byte[] bytes = uuidPtr.getByteArray(0, 16);
            ByteBuffer bb = ByteBuffer.wrap(bytes);
            long high = bb.getLong();
            long low = bb.getLong();
            this.value = new UUID(high, low);
            this.rawPointer = null;
        }
        return (UUID)this.value;
    }

    @Override
    public void close() {
        Log.i("TypedValue", "close");

        if (this.rawPointer != null) {
            JNA.INSTANCE.typed_value_destroy(this.rawPointer);
        }
    }
}
