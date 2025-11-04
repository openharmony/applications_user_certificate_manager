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
import { CertAbstractVo } from '../model/CertManagerVo/CertAbstractVo';

export class CmCertDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  public originDataArray: CertAbstractVo[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  public getData(index: number): CertAbstractVo {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  reloadData(certList: CertAbstractVo[]) {
    this.originDataArray = certList;
    this.listeners.forEach((listener) => {
      listener.onDataReloaded();
    })
  }
}