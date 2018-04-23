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

import com.sun.jna.Pointer;
import com.sun.jna.Structure;

import java.io.Closeable;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class RustResult extends Structure implements Closeable {
    public static class ByReference extends RustResult implements Structure.ByReference {
    }

    public static class ByValue extends RustResult implements Structure.ByValue {
    }

    public Pointer ok;
    public String err;

    public boolean isSuccess() {
        return this.ok != null;
    }

    public boolean isFailure() {
        return this.err != null;
    }

    @Override
    protected List<String> getFieldOrder() {
        return Arrays.asList("ok", "err");
    }

    @Override
    public void close() throws IOException {
        // TODO do we need to make sure the error string is memory managed properly?

        if (this.getPointer() != null) {
            JNA.INSTANCE.destroy(this.getPointer());
        }
    }
}