<img src="https://github.com/user-attachments/assets/ecac0d93-78db-4399-a877-13c97612b69d" alt="icon" width="400"/>

# ⏱ 배속 타이머, **빠른 타이머**

> 시간을 배속으로 흐르게 하여 집중력을 끌어올리는 타이머 앱  
> Flutter 기반 | Android / iOS 지원

> **빠른 타이머는 단순한 시간 측정 앱이 아닙니다.**  
> 작업의 속도를 높이고자 하는 사용자에게 **심리적 긴장감과 몰입도**를 제공하는 도구입니다.  
> 배속 타이머라는 새로운 개념을 통해, 단순 시간 측정을 넘어 **성과 향상과 기록 단축을 유도**합니다.

---

## ✨ 소개

**빠른 타이머**는 작업 시간이 한정된 상황에서 **시간의 흐름을 의도적으로 빠르게** 보여줌으로써  
사용자의 심리적 반응을 자극하고, 집중력과 속도 향상에 도움을 주는 타이머 앱입니다.

---

## 🎯 개발 배경

시험 문제 풀이, 인터벌 러닝, 속독 훈련 등 **시간 단축이 중요한 과제**를 수행할 때,  
실제보다 더 빠르게 시간이 흐르는 듯한 감각을 주면 **사용자는 긴장감을 갖고 더욱 집중하게 됩니다.**

이 앱은 그러한 심리적 요인을 기반으로,  
- **사용자가 설정한 배속만큼 빠르게 흐르는 시각적 타이머를 제공하고**  
- **그 결과를 기록 및 분석할 수 있는 기능**을 제공합니다.

---

## ⚙️ 주요 기능

- **배속 설정 타이머 생성**
  - 타이머를 1.0배속 ~ 3.0배속 사이에서 자유롭게 설정 가능
  - 예: "수능 국어 1.2배속", "3km 달리기 1.5배속" 등

- **실제 경과 시간 vs 화면 표시 시간 비교**
  - 타이머 종료 시 실제 소요 시간과 화면상 흐른 시간을 비교 표시
  - 목표 시간 대비 단축/초과 여부 확인 가능

- **기록 저장 및 분석**
  - 타이머별 기록 저장
  - 저장된 기록을 바탕으로 **그래프**, **최고 기록**, **추세 분석** 기능 제공

---

## 🎨 UI/UX 디자인
<img src="https://github.com/user-attachments/assets/63f731c5-9187-4105-96ed-11d8086ee55d" alt="UI" width="600"/>

---

## 🧩 기술 스택

| 분류            | 이름                                                                 |
|-----------------|----------------------------------------------------------------------|
| Architecture    | MVVM (`ViewModel - Repository - DAO`) 구조 구현                      |
| 상태 관리       | `MultiProvider`, `ChangeNotifier` 기반 상태관리                      |
| 비동기 처리     | `Future`, `async/await`, `Firebase Functions`                         |
| 데이터 처리     | `Provider` 기반 상태 연동 / JSON 파싱 / 날짜 연산                     |
| 데이터 저장     | `SharedPreferences`,`SQFLite`             |
| 알림            | `flutter_local_notifications`, 통한 타이머 시간 초과 알림 |
| 활용 API        | Google AdMob    |
| UI Frameworks   | Flutter, Material Design 위젯, 커스텀 테마(다크모드/라이트모드 지원)   |

---

## 🖼 스크린샷

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ffd92661-7ff5-432a-b860-70e9a326acb3" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/87abaf3e-2f68-4da6-9f08-9838c14afc20" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/defb58cb-fcbd-4c76-9143-850f729381c2" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/646fe4e1-483e-40f0-8350-3b0bd10d8102" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/7d235725-0314-4194-bc4a-865035101105" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/9f909adf-aac9-4a48-a497-e17d05ae00e7" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/9a221842-ec9e-4eaf-b747-ad0761ec4be1" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/039943d0-f91f-4e82-98f6-9b52237f15e2" width="200"/></td>
  </tr>
</table>


---

## 💰 비즈니스 모델

- **현재 수익 구조**
  - 📢 **광고 수익화**  
    Google AdMob 기반 광고를 타이머 종료 시점 등 사용자 흐름을 고려해 자연스럽게 배치

- **향후 수익 모델**
  - 💎 **프리미엄 버전 출시 예정**
    - 타이머 개수 제한 해제
    - 광고 제거
    - AI 기반 기록 분석 리포트 제공 (기록 개선도, 집중 구간, 실수 영역 등)
    - 타이머 커스터마이징 모드 제공
      - 예: **'버닝 모드'** (러닝 모드: 특정 구간 음성 안내 / 시간 도래 시 진동 / 목표 초과 시 경고음 등)

---

## 🔮 향후 계획

- 🔧 **AI 분석 기능 고도화**
  - 반복된 기록 기반으로 **사용자별 패턴을 학습**해 분석 보고서 제공
  - 목표 대비 단축 가능성, 집중 흐름 예측 등 맞춤형 피드백 제공

- 🧠 **개인화된 타이머 제공**
  - 운동/공부/업무 등 목적에 따라 타이머 UI와 피드백 방식을 자동 최적화

- 📢 **모티베이션 기능 추가**
  - 타이머 종료 시 음성 피드백, 랭킹 경쟁, 친구와 공유 기능 등 동기 부여 요소 확장

---

## 📲 다운로드

- [![App Store](https://img.shields.io/badge/App%20Store-%230078D6?style=for-the-badge&logo=apple&logoColor=white)]([<!-- 앱스토어 링크 -->](https://apps.apple.com/kr/app/%EB%B9%A0%EB%A5%B8-%ED%83%80%EC%9D%B4%EB%A8%B8-%EC%9E%91%EC%97%85-%ED%9A%A8%EC%9C%A8-%EA%B7%B9%EB%8C%80%ED%99%94%ED%95%98%EA%B8%B0/id6746601083))

---

## 📌 문의 / 피드백

이슈나 개선 요청은 GitHub Issues를 통해 전달해주세요.  
아이디어 제안, 사용자 경험 피드백 모두 적극 반영하고 있습니다.

---

## 📝 라이선스

본 프로젝트는 MIT License 하에 공개되어 있습니다.
