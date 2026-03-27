/*
 * Copyright (c) 2026-2026 Huawei Device Co., Ltd.
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

import hilog from '@ohos.hilog';

export default class Logger {
  private static readonly DOMAIN: number = 0x0000;
  private readonly tag: string;

  constructor(tag: string) {
    this.tag = tag;
  }

  public debug(format: string, ...args: Object[]): void {
    hilog.debug(Logger.DOMAIN, this.tag, format, ...args);
  }

  public info(format: string, ...args: Object[]): void {
    hilog.info(Logger.DOMAIN, this.tag, format, ...args);
  }

  public warn(format: string, ...args: Object[]): void {
    hilog.warn(Logger.DOMAIN, this.tag, format, ...args);
  }

  public error(format: string, ...args: Object[]): void {
    hilog.error(Logger.DOMAIN, this.tag, format, ...args);
  }

  public fatal(format: string, ...args: Object[]): void {
    hilog.fatal(Logger.DOMAIN, this.tag, format, ...args);
  }
}
