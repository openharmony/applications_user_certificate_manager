# 用户证书管理部件

  - [简介](#简介)
  - [目录](#目录)
  - [编译构建](#编译构建)
  - [说明](#说明)
  - [相关仓](#相关仓)

## 简介

用户证书管理是OpenHarmony中预置的系统应用，向用户提供CA证书和凭据的管理功能，主要的功能包含：

1、系统预置CA证书的查看；

2、用户CA证书的安装、查看、启用禁用与卸载；

3、用户证书凭据的安装、查看、授权管理与卸载；

4、系统证书凭据（WLAN/VPN证书凭据）的安装、查看、卸载功能；

用户证书管理部件架构如下图所示：

<div align=center>
<img src=doc/image/image-20220727141455437.png width=80% align=center/>

</div>

## 目录

```
├── BUILD.gn                                # 部件构建文件
├── build-profile.json5                     # 编译构建文件
├── bundle.json                             # 部件构建入口
├── certmanager                             # 业务证书管理模块目录
    └── src
        └── main
            ├── ets							# 代码目录
            │   ├── Application				# AbilityStage类实现
            │   ├── MainAbility				# Ability类实现
            │   ├── model					# model层功能类实现
            │   ├── pages					# 页面展示实现
            │   ├── presenter				# 页面presenter层功能类实现
            └── resources					# 资源文件目录
├── entry									# entry模块目录
├── hvigor                                  # 编译构建文件
├── hvigorfile.js                           # 编译构建文件
├── hvigorw                                 # 编译构建文件
├── LICENSE                                 # 许可文件
├── OAT.xml
├── oh-package.json5                        # 编译构建文件
├── README.md
└── signature                               # 签名profile文件
```

## 编译构建

**单仓编译**

以RK3568为例，在OpenHarmony源码根目录下调用以下指令，单独编译用户证书管理部件。

```shell
./build.sh --product-name rk3568 --ccache --build-target user_certificate_manager
```

> **说明：**
>
> --product-name：产品名称，例如rk3568。
>
> --ccache：编译时使用缓存功能。
>
> --build-target: 编译的部件名称。


## 说明

### 接口说明

不涉及。

### 使用说明

不涉及。


## 相关仓

[security_certificate_manager](https://gitee.com/openharmony/security_certificate_manager)

[**applications_user_certificate_manager**](https://gitee.com/openharmony-sig/applications_user_certificate_manager)

