---
title: "[Java Eclipse] 나만의 자동 완성(template) 설정하기"
date: 2025-06-25 18:07:00 +09:00
categories: [Java, Eclipse]
tags: [java, eclipse 자동완성, 설정, tool, template]
---

이번 포스팅에선 이클립스(Eclipse)에서 Template 기능을 활용하여 자주 사용하는 구문을 지정해 사용자 정의 자동완성을 사용할 수 있게 설정하는 방법을 소개합니다. 

<br>

## ✅ Template 설정하기

메뉴바의 [Window] - [Preferences] 창을 엽니다. 

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-06-25-java-01.png)


[Java] - [Editor] - [Templates]에서 [New...] 버튼을 클릭한 후 

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-06-25-java-02.png)

`Name`에 줄임말로 사용할 구문, `Description`에 템플릿에 대한 설명, `Pattern`에 자동 완성할 코드를 입력합니다.

저는 알고리즘 문제를 풀 때 `StringTokenizer`를 자주 사용하기 때문에 `stk`를 입력하면 자동으로 완성되게 설정하였습니다. 

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-06-25-java-03.png)

입력 완료 후 [OK] - [Apply] - [Apply and Close]를 눌러 설정을 적용합니다. 

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-06-25-java-04.png)

그리고 에디터 창에서 입력했던 name을 쓰고 `Ctrl + space`를 누르면 이렇게 설정했던 구문이 바로 나타나 사용할 수 있습니다. 

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-06-25-java-05.png)

<br>
