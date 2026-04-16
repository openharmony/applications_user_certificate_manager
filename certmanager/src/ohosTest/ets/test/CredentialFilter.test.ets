/**
 * Copyright (c) 2022-2024 Huawei Device Co., Ltd.
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

import { describe, it, expect } from '@ohos/hypium';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  CompositeCertificateFilter,
  CredentialFilter,
  CredentialFilterBuilder,
  CredentialFilterCriteria,
  CertChainProvider,
  ICertificateFilter,
  IssuerFilter,
  KeyAlgorithmFilter,
  UkeyCredentialCertChainProvider
} from '../../../main/ets/feature/requestAuth/common/CredentialFilter';
import { CredentialAbstractVo } from '../../../main/ets/model/CertManagerVo/CredentialAbstractVo';
import { JSON, util } from '@kit.ArkTS';
import { cert } from '@kit.DeviceCertificateKit';

const rsaCa = `-----BEGIN CERTIFICATE-----
MIIDmzCCAoOgAwIBAgIUVKMJE/c1wJ/K/86si9c5GGSKkcUwDQYJKoZIhvcNAQEL
BQAwdTELMAkGA1UEBhMCQ04xEDAOBgNVBAgMB0JlaWppbmcxEDAOBgNVBAcMB0Jl
aWppbmcxDTALBgNVBAoMBE15Q0ExHjAcBgNVBAsMFUNlcnRpZmljYXRlIEF1dGhv
cml0eTETMBEGA1UEAwwKTXkgUm9vdCBDQTAeFw0yNjAzMjQxMDE0MTJaFw0zNjAz
MjExMDE0MTJaMHUxCzAJBgNVBAYTAkNOMRAwDgYDVQQIDAdCZWlqaW5nMRAwDgYD
VQQHDAdCZWlqaW5nMQ0wCwYDVQQKDARNeUNBMR4wHAYDVQQLDBVDZXJ0aWZpY2F0
ZSBBdXRob3JpdHkxEzARBgNVBAMMCk15IFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCnEVCg3bDT/Hk2mNDnONm3P2HhNRPYCX6QYuPBJrJh
XlUmKpbhoCw0BCp+I6SqR3DF2D5f5B1jsWY9IPnl6txZ+iIIHXvBND7f9OdR2xmi
z7ebGOziDK9FPyyV/abSJyXVsbqa1hgNU5QgeTIwg/9skTgReF9VaAGoykzXY86+
dXKXfeWc/6Gb6W6yvGv+txYUlCwtC4wWxm1e6YTmZ+ovpTfZgFAcMtIZRmYjdGVo
E5yJz4o+gHEV8qMPTx3XbKmO1dZ9AI2jydYSqaJ/7WfXe4jPbWCtab83itpYNwk6
k/02Q6hFHRXd40qHDm4PyVOR99juhkgMI8W5lt84+4qRAgMBAAGjIzAhMA8GA1Ud
EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IBAQA8
+bMsW9VNkHq1nWFHqK/qpH4AtrSlKfvA77cA74retUnpamRs4sRcT2x+/PeDgSGh
8IF7iRHoAHTcgxcDJ0TZdO5LOOwj+YQuuU3ELBp+kPF9AFDOGncPfrcTuNVBdtf5
UDIqLa3T+9zEWsMC7TJ2Vg2z0V5web/z3i2ZYSKC5uZvHQVNk7wiI+iCFf2XNY2D
yfvNGrp7JJ2Ln0RmSbhQcwIzR2/LHL7oMAnNENsSupBQmrWe4EEVJHivyBOWh7/C
NgVww8Mi0lveO2QjrPEYB5dgG8g5L0Gsp1p/68go2H0OAqx4uIK2zVXlfGdcRsfl
5XdkY7xndKBv/EkaWqd1
-----END CERTIFICATE-----`;

const rsaCertChain = `-----BEGIN CERTIFICATE-----
MIIDsTCCApmgAwIBAgIUQkAxyPMA/cUbIO87XvXOXJa7x4YwDQYJKoZIhvcNAQEL
BQAwdTELMAkGA1UEBhMCQ04xEDAOBgNVBAgMB0JlaWppbmcxEDAOBgNVBAcMB0Jl
aWppbmcxDTALBgNVBAoMBE15Q0ExHjAcBgNVBAsMFUNlcnRpZmljYXRlIEF1dGhv
cml0eTETMBEGA1UEAwwKTXkgUm9vdCBDQTAeFw0yNjAzMjQxMDE1MThaFw0yNzAz
MjQxMDE1MThaMHIxCzAJBgNVBAYTAkNOMRAwDgYDVQQIDAdCZWlqaW5nMRAwDgYD
VQQHDAdCZWlqaW5nMQ4wDAYDVQQKDAVNeU9yZzEWMBQGA1UECwwNSVQgRGVwYXJ0
bWVudDEXMBUGA1UEAwwOTXkgQ2VydGlmaWNhdGUwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQC8J3Kl7KpKIViR7BS2jDPaU6r2Hreu+Hmtgin4z+KvsZ6M
7ThWuq1lhPdhQOIPfs/E2FWztaA+eXk/mtOgyS1vgv6h6JYB/Vw/MVXrKzzwJeOY
b3M5TdoTjgw0Fym6z3WZjIkMAGQhqOL1niH2R6PSmCK0FecnMcvhwPMeuoFPMR38
/WUuBlMN19exkUff4P5gmkjzPqb1g/7gkHUTPyznEK7Ewz2vMgbDV5BAFKw9YbKn
1/SyhQJWqi2omgoHHAWKx19vCm2EF/LDbEt759CheSAGgEC7ocnzyvg8LBtDizKb
XcBu2INlHROKOXXL+pvUMjWGc4x9BtLy4/8od26ZAgMBAAGjPDA6MAkGA1UdEwQC
MAAwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcD
AjANBgkqhkiG9w0BAQsFAAOCAQEAft8HG6DSv2Kwzwg24GDH4Uc2yAF21S8kMvYo
R8GXdLeGg2AFQ+0KYGfjAWSeW6Ew2KWg5e2pupm9hWCAlxxW5RRg1/wWumhDHuhg
rE5bkHzJYajKWiMaeiKYQA+v+NfQObrnNd3GHdnVv/2Mu/iS/Liobcm3OtXRQBz0
5w7fUUKgGplw4TFoRhvnXgddUa7LrNu0HQ/OsUe9XYNHJ3cy3MZJPVqMEireryhU
Dh23EwWI/agN69McX9ZAzT5iyO5P1CRyE3vBv0otTaRBpung3tJ/im4g0tmvN8Jf
s91qN3IU5rvrWtCis41H4pEsTsuJD9rrVLDPS48GIf8l8kEb2A==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDmzCCAoOgAwIBAgIUVKMJE/c1wJ/K/86si9c5GGSKkcUwDQYJKoZIhvcNAQEL
BQAwdTELMAkGA1UEBhMCQ04xEDAOBgNVBAgMB0JlaWppbmcxEDAOBgNVBAcMB0Jl
aWppbmcxDTALBgNVBAoMBE15Q0ExHjAcBgNVBAsMFUNlcnRpZmljYXRlIEF1dGhv
cml0eTETMBEGA1UEAwwKTXkgUm9vdCBDQTAeFw0yNjAzMjQxMDE0MTJaFw0zNjAz
MjExMDE0MTJaMHUxCzAJBgNVBAYTAkNOMRAwDgYDVQQIDAdCZWlqaW5nMRAwDgYD
VQQHDAdCZWlqaW5nMQ0wCwYDVQQKDARNeUNBMR4wHAYDVQQLDBVDZXJ0aWZpY2F0
ZSBBdXRob3JpdHkxEzARBgNVBAMMCk15IFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCnEVCg3bDT/Hk2mNDnONm3P2HhNRPYCX6QYuPBJrJh
XlUmKpbhoCw0BCp+I6SqR3DF2D5f5B1jsWY9IPnl6txZ+iIIHXvBND7f9OdR2xmi
z7ebGOziDK9FPyyV/abSJyXVsbqa1hgNU5QgeTIwg/9skTgReF9VaAGoykzXY86+
dXKXfeWc/6Gb6W6yvGv+txYUlCwtC4wWxm1e6YTmZ+ovpTfZgFAcMtIZRmYjdGVo
E5yJz4o+gHEV8qMPTx3XbKmO1dZ9AI2jydYSqaJ/7WfXe4jPbWCtab83itpYNwk6
k/02Q6hFHRXd40qHDm4PyVOR99juhkgMI8W5lt84+4qRAgMBAAGjIzAhMA8GA1Ud
EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IBAQA8
+bMsW9VNkHq1nWFHqK/qpH4AtrSlKfvA77cA74retUnpamRs4sRcT2x+/PeDgSGh
8IF7iRHoAHTcgxcDJ0TZdO5LOOwj+YQuuU3ELBp+kPF9AFDOGncPfrcTuNVBdtf5
UDIqLa3T+9zEWsMC7TJ2Vg2z0V5web/z3i2ZYSKC5uZvHQVNk7wiI+iCFf2XNY2D
yfvNGrp7JJ2Ln0RmSbhQcwIzR2/LHL7oMAnNENsSupBQmrWe4EEVJHivyBOWh7/C
NgVww8Mi0lveO2QjrPEYB5dgG8g5L0Gsp1p/68go2H0OAqx4uIK2zVXlfGdcRsfl
5XdkY7xndKBv/EkaWqd1
-----END CERTIFICATE-----`;

const ecCertChain = `-----BEGIN CERTIFICATE-----
MIICOjCCAeCgAwIBAgIUYYzhiAc5oHPLLOClE2vksRc75JwwCgYIKoZIzj0EAwIw
gYExCzAJBgNVBAYTAkNOMRAwDgYDVQQIDAdCZWlqaW5nMRAwDgYDVQQHDAdCZWlq
aW5nMREwDwYDVQQKDAhNeUVDQ19DQTEiMCAGA1UECwwZRUNDIENlcnRpZmljYXRl
IEF1dGhvcml0eTEXMBUGA1UEAwwOTXkgRUNDIFJvb3QgQ0EwHhcNMjYwMzI0MTI1
NzMwWhcNMjcwMzI0MTI1NzMwWjB6MQswCQYDVQQGEwJDTjEQMA4GA1UECAwHQmVp
amluZzEQMA4GA1UEBwwHQmVpamluZzESMBAGA1UECgwJTXlFQ0NfT3JnMRYwFAYD
VQQLDA1JVCBEZXBhcnRtZW50MRswGQYDVQQDDBJNeSBFQ0MgQ2VydGlmaWNhdGUw
WTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQvAlAdjd84jAsns/I40Ol3bRlCpyW+
/bo/fq3IF+CtOdabUrq6csasdNShi7AjL5uUJv8LjT4uHrdDlgl17FJiozwwOjAJ
BgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYI
KwYBBQUHAwIwCgYIKoZIzj0EAwIDSAAwRQIhAJx7d1+XOTHPNHmRQIKTNr2wGTui
5U/6ZlTHyIYfVQWXAiAS58Svqiwjpu2N98CIfsizu6YTh6MGAS4/2pdVaAhQNw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIICKTCCAc+gAwIBAgIUdWnifkdseiOnZsQBonWH/QvfbVUwCgYIKoZIzj0EAwIw
gYExCzAJBgNVBAYTAkNOMRAwDgYDVQQIDAdCZWlqaW5nMRAwDgYDVQQHDAdCZWlq
aW5nMREwDwYDVQQKDAhNeUVDQ19DQTEiMCAGA1UECwwZRUNDIENlcnRpZmljYXRl
IEF1dGhvcml0eTEXMBUGA1UEAwwOTXkgRUNDIFJvb3QgQ0EwHhcNMjYwMzI0MTI1
NjA3WhcNMzYwMzIxMTI1NjA3WjCBgTELMAkGA1UEBhMCQ04xEDAOBgNVBAgMB0Jl
aWppbmcxEDAOBgNVBAcMB0JlaWppbmcxETAPBgNVBAoMCE15RUNDX0NBMSIwIAYD
VQQLDBlFQ0MgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRcwFQYDVQQDDA5NeSBFQ0Mg
Um9vdCBDQTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABM5Lug+4t3b1AKy+sX+2
OMk7LT0uZmuPpetqjjS/B34BEf08tWeEczQrEsBarzo9OPCwdTYGLqXd30qnKjsF
f86jIzAhMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49
BAMCA0gAMEUCIQDJHxiLuDR700ZYxCLv/Gag/RHDOHydqU3S/OVO4rYSIgIgQGoD
GVgQsT1O3zuOzK43h50y7ZSw8arCklVEkAmXTxo=
-----END CERTIFICATE-----`;

const ecCertIssuer = new Uint8Array([
  0x30, 0x81, 0x81, 0x31, 0x0B, 0x30, 0x09, 0x06,
  0x03, 0x55, 0x04, 0x06, 0x13, 0x02, 0x43, 0x4E,
  0x31, 0x10, 0x30, 0x0E, 0x06, 0x03, 0x55, 0x04,
  0x08, 0x0C, 0x07, 0x42, 0x65, 0x69, 0x6A, 0x69,
  0x6E, 0x67, 0x31, 0x10, 0x30, 0x0E, 0x06, 0x03,
  0x55, 0x04, 0x07, 0x0C, 0x07, 0x42, 0x65, 0x69,
  0x6A, 0x69, 0x6E, 0x67, 0x31, 0x11, 0x30, 0x0F,
  0x06, 0x03, 0x55, 0x04, 0x0A, 0x0C, 0x08, 0x4D,
  0x79, 0x45, 0x43, 0x43, 0x5F, 0x43, 0x41, 0x31,
  0x22, 0x30, 0x20, 0x06, 0x03, 0x55, 0x04, 0x0B,
  0x0C, 0x19, 0x45, 0x43, 0x43, 0x20, 0x43, 0x65,
  0x72, 0x74, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74,
  0x65, 0x20, 0x41, 0x75, 0x74, 0x68, 0x6F, 0x72,
  0x69, 0x74, 0x79, 0x31, 0x17, 0x30, 0x15, 0x06,
  0x03, 0x55, 0x04, 0x03, 0x0C, 0x0E, 0x4D, 0x79,
  0x20, 0x45, 0x43, 0x43, 0x20, 0x52, 0x6F, 0x6F,
  0x74, 0x20, 0x43, 0x41
]);

class MockCertChainProvider extends CertChainProvider {
  private credentials: Map<string, string> = new Map<string, string>();

  constructor() {
    super();
    this.credentials.set('rsaCertChain.pem', rsaCertChain);
    this.credentials.set('eccCertChain.pem', ecCertChain);
    this.credentials.set('rsaCa.pem', rsaCa);
  }

  public async getCertChainData(credential: CredentialAbstractVo): Promise<Uint8Array | undefined> {
    let certData = this.credentials.get(credential.keyUri);
    if (!certData) {
      return undefined;
    }
    return new util.TextEncoder().encodeInto(certData);
  }
}

class MockCertificateFilter implements ICertificateFilter {
  private shouldPass: boolean;

  constructor(shouldPass: boolean = true) {
    this.shouldPass = shouldPass;
  }

  public async filter(certChain: cert.X509CertChain): Promise<boolean> {
    return Promise.resolve<boolean>(this.shouldPass);
  }
}

export default function credentialFilterTest() {
  describe('CredentialFilterTest', () => {
    it('CredentialFilterCriteriaBuilderPattern', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'CredentialFilterCriteria builder test start');
      
      const criteria = new CredentialFilterCriteria()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withIssuers([new Uint8Array([1, 2, 3])]);

      expect(criteria.keyAlgIds.length).assertEqual(2);
      expect(criteria.keyAlgIds[0]).assertEqual('RSA');
      expect(criteria.keyAlgIds[1]).assertEqual('EC');
      expect(criteria.issuers.length).assertEqual(1);
      expect(criteria.isEmpty()).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'CredentialFilterCriteria builder test end');
      done();
    });

    it('CredentialFilterCriteriaEmptyCriteria', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'Empty criteria test start');
      
      const criteria = new CredentialFilterCriteria();
      expect(criteria.isEmpty()).assertTrue();
      
      hilog.info(0x0000, 'testTag', 'Empty criteria test end');
      done();
    });

    it('KeyAlgorithmFilterRSAMapping', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter RSA test start');

      const filter = new KeyAlgorithmFilter(['RSA']);
      hilog.info(0x0000, 'testTag', `filter = ${JSON.stringify(filter)}`);
      expect(filter == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter RSA test end');
      done();
    });

    it('KeyAlgorithmFilterECMapping', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter EC test start');
      
      const filter = new KeyAlgorithmFilter(['EC']);
      expect(filter == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter EC test end');
      done();
    });

    it('KeyAlgorithmFilterECDSAMapping', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter ECDSA test start');
      
      const filter = new KeyAlgorithmFilter(['ECDSA']);
      expect(filter == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter ECDSA test end');
      done();
    });

    it('KeyAlgorithmFilterMultipleAlgorithms', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter multiple algorithms test start');
      
      const filter = new KeyAlgorithmFilter(['RSA', 'EC', 'ECDSA']);
      expect(filter == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'KeyAlgorithmFilter multiple algorithms test end');
      done();
    });

    it('IssuerFilterEmptyIssuers', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'IssuerFilter empty issuers test start');
      
      const filter = new IssuerFilter([]);
      expect(filter == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'IssuerFilter empty issuers test end');
      done();
    });

    it('CompositeCertificateFilterAddFilters', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'CompositeCertificateFilter add test start');
      
      const composite = new CompositeCertificateFilter();
      composite.addFilter(new MockCertificateFilter(true));
      composite.addFilter(new MockCertificateFilter(true));

      expect(composite == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'CompositeCertificateFilter add test end');
      done();
    });

    it('CredentialFilterSingletonPattern', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'CredentialFilter singleton test start');
      
      const instance1 = CredentialFilter.getInstance();
      const instance2 = CredentialFilter.getInstance();
      
      expect(instance1).assertEqual(instance2);
      
      hilog.info(0x0000, 'testTag', 'CredentialFilter singleton test end');
      done();
    });

    it('CredentialFilterBuilderBuilderPattern', 0, (done: Function) => {
      hilog.info(0x0000, 'testTag', 'CredentialFilterBuilder test start');
      
      const mockProvider = new MockCertChainProvider();
      const builder = new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA'])
        .withIssuers([new Uint8Array([1, 2, 3])])
        .withCertChainProvider(mockProvider);

      expect(builder == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'CredentialFilterBuilder test end');
      done();
    });

    it('CredentialFilterBuilderFilterEmptyCredentials', 0, async (done: Function) => {
      hilog.info(0x0000, 'testTag', 'Filter empty credentials test start');
      
      const mockProvider = new MockCertChainProvider();
      const credentials: CredentialAbstractVo[] = [];
      
      const builder = new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA'])
        .withCertChainProvider(mockProvider);
      
      const result = await builder.filter(credentials);
      expect(result.length).assertEqual(0);
      
      hilog.info(0x0000, 'testTag', 'Filter empty credentials test end');
      done();
    });

    it('CredentialFilterBuilderFilterWithEmptyCriteria', 0, async (done: Function) => {
      hilog.info(0x0000, 'testTag', 'Filter with empty criteria test start');
      
      const mockProvider = new MockCertChainProvider();
      const credentials = [
        new CredentialAbstractVo('public', 'test1', 'uri1'),
        new CredentialAbstractVo('public', 'test2', 'uri2')
      ];
      
      const builder = new CredentialFilterBuilder()
        .withCertChainProvider(mockProvider);
      
      const result = await builder.filter(credentials);
      expect(result.length).assertEqual(2);
      
      hilog.info(0x0000, 'testTag', 'Filter with empty criteria test end');
      done();
    });

    it('CredentialFilterFilterCredentials', 0, async (done: Function) => {
      hilog.info(0x0000, 'testTag', 'Filter credentials test start');
      
      const mockProvider = new MockCertChainProvider();
      const credentials = [
        new CredentialAbstractVo('public', 'test1', 'uri1'),
        new CredentialAbstractVo('public', 'test2', 'uri2')
      ];
      
      const criteria = new CredentialFilterCriteria()
        .withKeyAlgorithms(['RSA']);
      
      const result = await CredentialFilter.getInstance().filterCredentials(
        credentials,
        criteria,
        mockProvider
      );

      expect(result == null).assertFalse();
      
      hilog.info(0x0000, 'testTag', 'Filter credentials test end' );
      done();
    });

    /**
     * 测试条件为空
     */
    it('FilterEmptyCriteria', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
      new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms([])
        .withIssuers([])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(3);
      done();
    });

    /**
     * 测试无过滤器
     */
    it('FilterNoCriteria', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(3);
      done();
    });

    /**
     * 过滤ECC算法
     */
    it('FilterEcCert', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['ECDSA', 'EC'])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(1);
      expect(result[0].keyUri).assertEqual('eccCertChain.pem');
      done();
    });

    /**
     * 过滤RSA算法
     */
    it('FilterRsaCert', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA'])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(2);
      expect(result[0].keyUri).assertEqual('rsaCertChain.pem');
      done();
    });

    /**
     * 过滤RSA + ECC算法
     */
    it('FilterEcAndRsaCert', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'ECDSA', 'EC'])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(3);
      done();
    });

    /**
     * 过滤包含不支持的算法
     */
    it('FilterAlgNotSupport', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'DSA'])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(3);
      done();
    });

    /**
     * 过滤颁发者
     */
    it('FilterIssuer', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withIssuers([ecCertIssuer])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(1);
      expect(result[0].keyUri).assertEqual('eccCertChain.pem');
      done();
    });

    /**
     * 过滤颁发者 + 不支持的算法
     */
    it('FilterIssuerAndAlgNotSupport', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'DSA'])
        .withIssuers([ecCertIssuer])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(1);
      expect(result[0].keyUri).assertEqual('eccCertChain.pem');
      done();
    });

    /**
     * 过滤EC证书的颁发者 + RSA算法
     */
    it('FilterIssuerAndRsa', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA'])
        .withIssuers([ecCertIssuer])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(0);
      done();
    });

    /**
     * 过滤凭据列表中没有的颁发者
     */
    it('FilterIssuerNotExist', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = [
        new CredentialAbstractVo('', '', 'rsaCertChain.pem'),
        new CredentialAbstractVo('', '', 'eccCertChain.pem'),
        new CredentialAbstractVo('', '', 'rsaCa.pem')
      ]
      let issuer = new Uint8Array([0x00, 0x01, 0x02, 0x03]);
      const result = await new CredentialFilterBuilder()
        .withIssuers([issuer])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(0);
      done();
    });

    /**
     * 凭据列表空
     */
    it('FilterEmptyCredentials', 0, async (done: Function) => {
      const provider = new MockCertChainProvider();

      let credentials: Array<CredentialAbstractVo> = []
      const result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withIssuers([ecCertIssuer])
        .withCertChainProvider(provider)
        .filter(credentials);

      expect(result.length).assertEqual(0);
      done();
    });

    /**
     * 过滤Ukey证书测试
     */
    it('FilterUkeyCredentials', 0, async (done: Function) => {
      const provider = new UkeyCredentialCertChainProvider();

      let cred1 = new CredentialAbstractVo('', '', 'rsaCertChain.pem');
      let cred2 = new CredentialAbstractVo('', '', 'eccCertChain.pem');
      let cred3 = new CredentialAbstractVo('', '', 'rsaCa.pem');
      cred1.credData = new util.TextEncoder().encodeInto(rsaCertChain);
      cred2.credData = new util.TextEncoder().encodeInto(ecCertChain);
      cred3.credData = new util.TextEncoder().encodeInto(rsaCa);
      let credentials: Array<CredentialAbstractVo> = [cred1, cred2, cred3]
      let issuer = new Uint8Array([0x00, 0x01, 0x02, 0x03]);
      let result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withCertChainProvider(provider)
        .filter(credentials);
      expect(result.length).assertEqual(3);

      result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA'])
        .withCertChainProvider(provider)
        .filter(credentials);
      expect(result.length).assertEqual(2);

      result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['EC', 'ECDSA'])
        .withCertChainProvider(provider)
        .filter(credentials);
      expect(result.length).assertEqual(1);

      result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withIssuers([ecCertIssuer, issuer])
        .withCertChainProvider(provider)
        .filter(credentials);
      expect(result.length).assertEqual(1);

      result = await new CredentialFilterBuilder()
        .withKeyAlgorithms(['RSA', 'EC'])
        .withIssuers([issuer])
        .withCertChainProvider(provider)
        .filter(credentials);
      expect(result.length).assertEqual(0);
      done();
    });
  });
}
