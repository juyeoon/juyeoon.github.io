---
title: "[Linux] hostname을 변경하는 방법 총 정리 (임시 변경 vs 영구 변경) "
date: 2026-08-25 11:21:32 +09:00
categories: [Linux, System]
tags:
  [linux, hostname, hostnamectl, network]
description: "hostname이 무엇인지 알아보고 honstname을 변경하는 방법에 대해서 정리한다."
---

<br/>


## 📌 **hostname이란?**

hostname은 네트워크에 연결된 장치에 붙여진 고유한 이름이다. 네트워크 안에서 구별할 때 사용할 수 있고, 복잡한 숫자 형태의 IP 주소 대신 이름을 사용해 통신할 수 있다.

리눅스에는 3가지의 hostname이 존재한다.

| 종류               | 설명                                                             |
| ------------------ | ---------------------------------------------------------------- |
| Static hostname    | `/etc/hostname`에 저장되는 고정 이름. 재부팅해도 유지됨          |
| Transient hostname | 커널이 런타임에 관리하는 이름. DHCP 등으로 임시 할당될 수 있음   |
| Pretty hostname    | 사람이 읽기 좋은 이름 (예: "나의 개발 서버", 특수문자/공백 허용) |

보통 우리가 hostname을 바꾼다고 하면 <u>'Static hostname'</u>을 바꾼다는 것을 의미한다.

<u>Transient hostname</u>은 DHCP 환경이나 특정 네트워크 설정에서 커널이 런타임에 임시로 관리하는 이름이다. 사용자가 직접 건들일 일은 거의 없고, 보통 Static hostname과 같은 값을 그대로 따라간다.

<u>Pretty hostname</u>은 공백이나 특수문자, 한글 같은 걸 넣어서 사람이 읽기 좋은 이름을 붙이고 싶을 때 사용한다. 시스템 동작에는 영향이 없고, GUI 도구나 일부 관리 화면에서 보여주는 용도이다.


<br/>

## 🔍 **현재 hostname 확인하기**

hostname을 변경하기 전에 현재 hostname을 확인해본다.

```bash
hostname
```

```bash
ubuntu@ip-10-0-3-83:~$ hostname
ip-10-0-3-83
```

또는 더 자세한 정보를 보고 싶다면

```bash
hostnamectl status
```

```bash
ubuntu@ip-10-0-3-83:~$ hostnamectl status
 Static hostname: ip-10-0-3-83
       Icon name: computer-vm                                  # 데스크톱 환경 등에서 이 장비를 표시할 때 쓸 아이콘 종류
         Chassis: vm 🖴                                         # 하드웨어 형태 분류.
      Machine ID: ec2179af4672b934b502510bd5fffe96             # 이 시스템을 고유하게 식별하는 ID. /etc/machine-id에 저장됨
         Boot ID: c09d4008fb914d9cae9fb6189ddd0b95             # 이번 부팅 세션의 고유 ID. 재부팅할 때마다 값이 바뀜
  Virtualization: amazon                                       # 어떤 가상화 기술 위에서 돌고 있는지. AWS Nitro/EC2 환경이라는 의미
Operating System: Ubuntu 24.04.4 LTS                           # 설치된 OS 버전
          Kernel: Linux 7.0.0-1011-aws                         # 커널 버전
    Architecture: x86-64                                       # CPU 아키텍처
 Hardware Vendor: Amazon EC2                                   # 하드웨어(인스턴스) 제공자
  Hardware Model: t3.medium                                    # EC2 인스턴스 타입
Firmware Version: 1.0                                          # 하드웨어(하이퍼바이저) 펌웨어 정보
   Firmware Date: Mon 2017-10-16
    Firmware Age: 8y 10month 1w 1d

```

## ⚡ **임시로 변경하기: `hostname` 명령어**

hostname으로 새 hostname을 지정할 수 있는데 __<u>이 방법은 재부팅하면 원래대로 돌아온다.</u>__

```bash
sudo hostname {new-hostname}
```

<br/>

## 🔧 **영구적으로 변경하기: `hostnamectl`**

systemd 기반 배포판(Ubuntu 16.04+, CentOS/RHEL 7+, Debian 8+ 등)에서는 `hostnamectl`을 사용하는 게 정석이라고 한다.

(참고: Apline은 systemd 기반이 아니다)

```bash
sudo hostnamectl set-hostname {new-hostname}
```

이 명령어로 두 가지가 자동으로 처리된다.

1. `/etc/hostname` 파일 내용 변경
2. 커널의 런타임 hostname 즉시 반영 ⇒ 이게 바뀌어야 시스템 전체에 즉시 반영된다

자세하게 설명하자면, 

리눅스 커널은 `UTS namespace`라는 곳에 현재 hostname이 하나 있는데, `hostname`, `uname -n`, 셸 프롬프트에 찍히는 이름 등은 전부 커널 값을 직접 읽어오는 것이다.

`/etc/hostname`은 단순 텍스트 저장소이고, 부팅 시 참고용이다.

그래서 만약 커널 hostname만 바꾸고 `/etc/hostname`을 바꾸지 않는다면, 지금 당장은 `hostname`, `hostnamectl status`로 확인하면 새 hostname으로 잘 바뀐 것처럼 보이지만, 재부팅하면 부팅 스크립트가 `/etc/hostname`을 읽어서 커널에 다시 세팅해서 이전 hostname으로 원상복구 한다.

`/etc/hostname`만 바꾸게 된다면, 재부팅 할 때 새 hostname으로 바뀌게 될 것이다. 

그래서 `hostnamectl set-hostname`으로 파일과 커널 값을 한 번에 맞춰서 바꾸는 게 안전하다.

참고: 커널의 런타임(tansient) hostname만 바꾸고 싶다면,

```bash
sudo hostnamectl set-hostname {new-name} --transient
```

## 🌐 **`/etc/hosts` 파일도 함께 수정하기**

hostname을 바꿨다면 `/etc/hosts`도 같이 확인해줘야 한다. 

이름이 비슷해보이지만 `/etc/hosts`와 `/etc/hostname`은 완전히 다른 파일이다.

- `/etc/hostname`: 이 시스템 자신의 이름을 저장
- `/etc/hosts`: IP 주소 ↔ 이름 매핑 테이블 (로컬 DNS 역할)

```bash
# /etc/hostname
ip-10-0-3-83
```

```bash
# /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
```

다시 돌아와서, `/etc/hosts`를 확인해야 하는 이유:

```
sudo: unable to resolve host new-hostname: Name or service not known
```

`sudo`는 실행할 때 자기 자신의 hostname을 IP로 reslove하려고 시도한다.
그런데 `/etc/hostname`에는 `new-hostname`이라고만 적혀있고, `/etc/hosts`에는 그 이름에 대응하는 IP 항목이 없으면 조회에 실패하기 때문에 저 경고가 뜬다.

참고: 무조건 `/etc/hostname`에 명시되어 있지 않다고 저 경고가 나오는 건 아니다. 여러 조건이 모두 만족해야 경고가 발생한다.


**그래서** `/etc/hosts` 파일을 열어서 기존 hostname을 새 hostname으로 바꿔줘야 한다.

```bash
sudo vi /etc/hosts
```
```
127.0.0.1   localhost
127.0.1.1   {new-hostname}
```

`127.0.1.1` 줄이 없다면 새로 추가해주면 된다.

## 🐧 **배포판별 차이점**

| 배포판                         | 권장 방법                                                                           | 비고                                |
| ------------------------------ | ----------------------------------------------------------------------------------- | ----------------------------------- |
| Ubuntu / Debian                | `hostnamectl set-hostname`                                                          | /etc/hostname, /etc/hosts 함께 수정 |
| CentOS / RHEL 7+               | `hostnamectl set-hostname`                                                          | systemd 기반이면 동일               |
| CentOS 6 이하                  | `/etc/sysconfig/network`의 `HOSTNAME` 값 수정                                       | systemd 이전 방식                   |
| 클라우드 인스턴스 (AWS EC2 등) | `hostnamectl` 사용 가능하나, DHCP/cloud-init 설정에 의해 재부팅 시 되돌아갈 수 있음 | cloud-init 설정 확인 필요           |

🧾: 실제로 AWS EC2에 ubuntu 24.04 LTS를 올려서 확인해본 결과 reboot 해도 hostname이 잘 적용되더라.
⇒ 찾아보니 매 부팅마다 실행되는 건 아니더라. `set_hostname`이라는 모듈이 실행될 때 hostname을 건드릴지 말지 결정하는 옵션을 `preserve_hostname`라고 하는데(cloud-init 설정), `preserve_hostname`과 상관 없이 `set_hostname` 모듈은 매 재부팅마다 실행되지는 않는다고 한다.

## ✅ **변경 확인 및 마무리**

모든 설정이 끝났다면 아래 명령어들로 최종 확인한다.

```bash
hostname                # 현재 hostname
hostnamectl status      # 상세 정보
cat /etc/hostname       # static hostname 파일 확인
cat /etc/hosts          # hosts 파일 확인
```

셸 프롬프트에 반영된 hostname을 바로 확인하고 싶다면, 새 터미널 세션을 열거나 재로그인하면 된다.

## 👉 **정리**

-임시 변경: `hostname new-hostname` → 재부팅하면 초기화

-영구 변경: `hostnamectl set-hostname new-hostname` → `/etc/hostname`까지 반영

-함께 챙길 것: `/etc/hosts` 수정, 클라우드 환경이면 cloud-init 설정 확인

