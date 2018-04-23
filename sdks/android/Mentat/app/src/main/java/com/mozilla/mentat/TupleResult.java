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

import java.nio.ByteBuffer;
import java.util.Date;
import java.util.UUID;

public class TupleResult extends RustObject {

    public TupleResult(Pointer pointer) {
        this.rawPointer = pointer;
    }

    public TypedValue get(Integer index) {
        this.validate();
        Pointer pointer = JNA.INSTANCE.value_at_index(this.rawPointer, index);
        if (pointer == null) {
            return null;
        }
        return new TypedValue(pointer);
    }

    public Long asLong(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_long(this.rawPointer, index);
    }

    public Long asEntid(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_entid(this.rawPointer, index);
    }

    public String asKeyword(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_kw(this.rawPointer, index);
    }

    public Boolean asBool(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_boolean(this.rawPointer, index) == 0 ? false : true;
    }

    public Double asDouble(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_double(this.rawPointer, index);
    }

    public Date asDate(Integer index) {
        this.validate();
        return new Date(JNA.INSTANCE.value_at_index_as_timestamp(this.rawPointer, index));
    }

    public String asString(Integer index) {
        this.validate();
        return JNA.INSTANCE.value_at_index_as_string(this.rawPointer, index);
    }

    public UUID asUUID(Integer index) {
        this.validate();
        Pointer uuidPtr = JNA.INSTANCE.value_at_index_as_uuid(this.rawPointer, index);
        byte[] bytes = uuidPtr.getByteArray(0, 16);
        ByteBuffer bb = ByteBuffer.wrap(bytes);
        long high = bb.getLong();
        long low = bb.getLong();

        return new UUID(high, low);
    }

    @Override
    public void close() {
        Log.i("TupleResult", "close");
        if (this.rawPointer != null) {
            JNA.INSTANCE.typed_value_list_destroy(this.rawPointer);
        }
    }
}
