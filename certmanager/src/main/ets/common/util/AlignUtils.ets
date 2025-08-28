/**
 * Copyright (c) 2025-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Configuration, { LocaleResponse } from '@system.configuration'
import hilog from '@ohos.hilog';

const DOMAIN = 0x0000;
const TAG = 'AlignUtils';

export class AlignUtils {
    public static isRtl(): boolean {
        let isRtl: boolean = false;
        try {
            let localInfo: LocaleResponse = Configuration.getLocale();
            if (localInfo !== undefined && localInfo !== null) {
                isRtl = localInfo.dir === 'rtl';
            }
        } catch (error) {
            hilog.error(DOMAIN, TAG, `get local error, code: ${error?.code}, message: ${error?.message}`);
        }
        return isRtl;
    }
}