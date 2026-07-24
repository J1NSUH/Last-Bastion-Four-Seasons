# Technical Architecture

이 문서는 **Last Bastion: Four Seasons**를 구현할 때의 기술 구조를 정리합니다.

엔진을 특정하지 않고, 어떤 엔진을 쓰더라도 유지해야 할 시스템 경계와 데이터 흐름을 기준으로 작성합니다.

## 기술 목표

- 전투 판정은 재현 가능해야 합니다.
- 카드, 적, 웨이브, 아티팩트는 데이터 기반으로 동작해야 합니다.
- 경로 탐색과 구조물 배치는 전투의 핵심이므로 명확히 분리합니다.
- 웨이브 겹치기는 보상 로직과 분리합니다.
- UI는 시뮬레이션 상태를 읽지만, 핵심 전투 판정을 직접 바꾸지 않습니다.
- 멀티플레이를 고려해 명령 입력과 시뮬레이션 처리를 분리합니다.

## 상위 모듈

| 모듈 | 역할 |
| --- | --- |
| GameSession | 런 전체 상태, 일자, 계절, 승패, 저장, 런 시작 고정값 |
| RunConfigBuilder | 로비 설정을 RunState로 확정 |
| ScalingSystem | 인원수별 활성 방향과 스케일링 프로필 조회 |
| CombatSimulation | 전투 틱, 적 이동, 공격, 상태이상, 처치 |
| MapGrid | 타일, 경로 비용, 설치 가능 여부 |
| Pathfinding | 적 경로 계산과 길막 검증 |
| StructureSystem | 타워, 바리케이드, 함정, 오라, 파괴 |
| EnemySystem | 적 스폰, 이동, 행동, 사망 |
| CardSystem | 덱, 손패, 카드 사용, 버리기 |
| ResourceSystem | 시드 마나, 전투 마나, 드로우 게이지, 골드 |
| WaveSystem | 웨이브 계획 생성, 겹치기, 종료 정산 |
| WaveSpawnPlanner | RunState와 웨이브 원본 데이터를 조합해 WaveSpawnPlan 생성 |
| WaveScheduler | 확정된 WaveSpawnPlan의 시작 시점과 겹치기 예약 관리 |
| BossSystem | 보스 본체, 부위, 패턴, 기지 도달 |
| ArtifactSystem | 아티팩트 슬롯과 전역 효과 |
| ShopSystem | 구매, 제거, 강화, 가격 증가 |
| VoteSystem | 웨이브 겹치기, 아티팩트, 파티 자원 투표 |
| PingSystem | 협동 핑 생성, 동의, 맡음 표시, 자동 만료 |
| TelemetrySystem | 테스트 지표 기록 |
| Presentation | UI, 사운드, 이펙트, 카메라 |

### 접근성/연출 설정 경계

접근성과 연출 설정은 `Presentation` 계층의 플레이어별 설정으로 관리합니다.

사용 기준은 `accessibility_presentation_options`입니다.

수정 가능한 값:

- UI 배율
- 카드 텍스트 크기
- 화면 흔들림 강도
- 카메라 관성
- 저주파 보스음 음량
- 경고음과 핑 소리 음량
- 경로선, 적 윤곽선, 보스 부위 강조 표시
- 색각 보조와 방향 라벨

수정 금지 값:

- `RunState`
- `WaveSpawnPlan`
- 적 체력과 적 수
- 기지 체력
- 보상량과 카드 후보 수
- 활성 침공 방향

접근성 설정은 클라이언트별 표현 차이만 만들고, 권위 판정과 밸런스 계산에는 들어가지 않습니다.

## 데이터 흐름

기본 흐름:

```text
Player Input
-> Command
-> Validation
-> Simulation
-> Events
-> State Update
-> Presentation
```

## 런 시작 데이터 흐름

런 시작은 전투보다 먼저 확정되는 단계입니다.

```text
Lobby Selection
-> RunConfig
-> RunConfigBuilder
-> playerCountAtStart 확정
-> ScalingSystem에서 activeDirections와 scalingProfileId 조회
-> RunState 생성
-> 첫 WaveSpawnPlan 생성
-> GameSession 시작
```

중요:

- `playerCountAtStart`는 로비에서 런을 시작하는 순간 고정합니다.
- `activeDirections`는 `playerCountAtStart`로 한 번만 계산합니다.
- `scalingProfileId`도 런 시작 시 고정합니다.
- 현재 접속 인원은 세션 상태일 뿐, 런 밸런스 기준이 아닙니다.

런 시작 이후에는 플레이어가 나가거나 재접속해도 위 세 값은 바뀌지 않습니다.

## 웨이브 생성 데이터 흐름

웨이브는 원본 데이터와 실제 스폰 계획을 분리합니다.

```text
WaveData
+ RunState.activeDirections
+ RunState.scalingProfileId
+ 현재 일자/계절
-> WaveSpawnPlanner
-> WaveSpawnPlan
-> WaveScheduler
-> EnemySystem
```

역할:

| 단계 | 책임 |
| --- | --- |
| WaveData | 제작자가 만든 원본 웨이브, 선호 방향과 적 조합 보유 |
| WaveSpawnPlanner | 활성 방향 필터, 방향 대체, 스케일링 적용 |
| WaveSpawnPlan | 실제 스폰 방향과 수량이 확정된 전투용 데이터 |
| WaveScheduler | 스폰 시작, 웨이브 겹치기, 예약 제거 관리 |
| EnemySystem | 확정된 계획대로 적 생성 |

`EnemySystem`은 인원수나 활성 방향을 다시 계산하지 않습니다.

비활성 방향을 여는 로직도 `EnemySystem`에 두지 않습니다.

웨이브 겹치기는 이미 만들어진 `WaveSpawnPlan`을 앞당길 뿐, 새 방향을 만들지 않습니다.

예시:

```text
카드 사용 입력
-> PlayCardCommand
-> 마나/대상/경로 검증
-> CardSystem 효과 적용
-> StructureBuiltEvent 또는 DamageEvent 발생
-> 경로 재계산
-> UI 갱신
```

## 명령과 이벤트

플레이어 입력은 바로 상태를 바꾸지 않습니다.

먼저 명령으로 변환하고, 검증 후 시뮬레이션에 적용합니다.

명령 예시:

| 명령 | 설명 |
| --- | --- |
| PlayCardCommand | 카드 사용 |
| DiscardCardCommand | 카드 버리기 |
| BuildStructureCommand | 구조물 설치 |
| RepairStructureCommand | 구조물 수리 |
| ProposeWaveStackCommand | 웨이브 겹치기 제안 |
| VoteCommand | 투표 |
| CreatePingCommand | 협동 핑 생성 |
| AcknowledgePingCommand | 핑 동의 또는 맡음 표시 |
| DismissPingCommand | 내 화면에서 핑 접기 |
| SelectRewardCommand | 카드 보상 선택 |
| PurchaseShopItemCommand | 상점 구매 |
| EquipArtifactCommand | 아티팩트 장착 |
| SelectArtifactCommand | 아티팩트 후보 선택 |
| StartShopSessionCommand | 상점 세션 시작 |
| StartRunCommand | 로비 설정으로 런 시작 |

이벤트 예시:

| 이벤트 | 설명 |
| --- | --- |
| RunStartedEvent | 런 시작과 RunState 확정 |
| StructureBuiltEvent | 구조물 설치 완료 |
| StructureDestroyedEvent | 구조물 파괴 |
| EnemyKilledEvent | 적 처치 |
| WavePlanCreatedEvent | WaveSpawnPlan 생성 |
| WaveStartedEvent | 웨이브 시작 |
| WaveStackedEvent | 웨이브 겹침 |
| WaveCompletedEvent | 웨이브 완료 |
| PingCreatedEvent | 협동 핑 생성 |
| PingAcknowledgedEvent | 핑 동의 또는 맡음 표시 |
| PingResolvedEvent | 핑 해소 또는 만료 |
| BossPartDestroyedEvent | 보스 부위 파괴 |
| BossRewardGrantedEvent | 보스 보상 지급 |
| ArtifactEquippedEvent | 아티팩트 장착 완료 |
| ShopSessionStartedEvent | 상점 세션 시작 |
| ShopPurchaseEvent | 상점 구매 완료 |
| BaseDamagedEvent | 기지 피해 |
| RunFailedEvent | 런 실패 |

## 시뮬레이션 틱

전투는 고정 틱으로 처리하는 것을 권장합니다.

## 핑 시스템 경계

`PingSystem`은 협동 표시 상태를 관리합니다.

전투 판정, 카드 사용, 마나 소비, 구조물 조작은 각자의 시스템이 처리합니다.

핑으로 할 수 있는 것:

- 전장 대상 표시
- 관련 카드나 구조물 하이라이트 요청
- 동의와 맡음 표시
- 자동 만료와 해소 이벤트 발행
- 텔레메트리 기록

핑으로 하면 안 되는 것:

- 다른 플레이어 카드 자동 사용
- 다른 플레이어 마나 소비
- 구조물 소유권 변경
- 웨이브 겹치기 즉시 실행
- 보스 부위 타겟 강제 변경

웨이브 호출 핑은 정식 `ProposeWaveStackCommand`나 투표 UI로 이어질 수 있지만, 핑 자체가 웨이브를 호출하지 않습니다.

권장:

- 시뮬레이션 20~30 ticks/sec
- 렌더링은 별도 프레임
- 배속은 틱을 더 빠르게 소비
- 자원 회복은 시간 경과가 아니라 이벤트 기반

배속 처리:

| 배속 | 처리 |
| --- | --- |
| 1x | 기본 틱 |
| 2x | 같은 틱을 더 빠르게 진행 |
| 3x | 솔로 또는 전원 동의 시 |

배속이 올라가도 마나가 자동 회복되지 않습니다.

처치와 웨이브 정산 이벤트만 자원을 만듭니다.

## 전투 처리 순서

각 틱에서 처리할 순서:

1. 입력 명령 큐 처리
2. 투표 상태 갱신
3. WaveScheduler가 시작할 WaveSpawnPlan 확인
4. EnemySystem이 확정된 계획대로 스폰 처리
5. 적 경로 추적과 이동
6. 도발 대상 갱신
7. 구조물 공격
8. 적 공격과 구조물 피해
9. 카드 지속 효과 처리
10. 상태이상 시간 감소
11. 사망과 파괴 처리
12. 자원 지급
13. 경로 재계산 요청 처리
14. 보스 패턴 처리
15. 승패 조건 확인
16. UI 이벤트 발행

경로 재계산은 매 틱 모든 적에게 수행하지 않습니다.

구조물 배치, 파괴, 잔해 생성, 보스 압력 타일 변화처럼 경로가 바뀌는 이벤트가 있을 때 요청합니다.

## 상태 소유권

| 상태 | 소유 모듈 |
| --- | --- |
| RunState | GameSession |
| playerCountAtStart | GameSession |
| activeDirections | GameSession |
| scalingProfileId | GameSession |
| 인원수별 스케일링 테이블 | ScalingSystem |
| 현재 일자/계절 | GameSession |
| 기지 체력 | GameSession |
| 타일과 경로 비용 | MapGrid |
| 적 위치와 체력 | EnemySystem |
| 구조물 위치와 체력 | StructureSystem |
| 덱/손패/버린 더미 | CardSystem |
| 마나/드로우/골드 | ResourceSystem |
| WaveSpawnPlan 생성 | WaveSpawnPlanner |
| 진행 중 웨이브와 예약 | WaveScheduler |
| 보스 부위 체력 | BossSystem |
| 장착 아티팩트 | ArtifactSystem |
| 투표 상태 | VoteSystem |

한 상태를 여러 시스템이 직접 수정하지 않게 합니다.

다른 시스템은 명령이나 이벤트를 통해 상태 변경을 요청합니다.

## 저장 데이터

자동 저장은 하루 시작, 상점 진입, 보스 처치 후, 아티팩트 선택 완료 시점에 수행합니다.

저장해야 할 것:

- 런 ID
- 랜덤 시드
- playerCountAtStart
- activeDirections
- scalingProfileId
- 현재 일자와 계절
- 기지 체력
- 파티 골드와 보스 파편
- 플레이어별 직업
- 플레이어별 덱, 손패, 버린 카드 더미
- 장착 아티팩트
- 상점 가격 증가 상태
- 해금 상태
- 프로필 메타 진행 상태
- 도감/보스 기록 해금 상태
- 훈련 장면 해금 상태
- 파티 연대기 ID 목록
- 다음 웨이브 예고 상태
- 생성된 다음 WaveSpawnPlan

MVP에서는 전투 중 저장을 제외합니다.

### 메타 저장 분리

런 저장과 프로필 메타 저장은 분리합니다.

`RunState`는 현재 런의 전투 상태를 저장하고, `ProfileState`는 런 밖에서 유지되는 해금과 기록을 저장합니다.

`ProfileState`에 저장할 것:

- `unlockedCardPoolIds`
- `unlockedArtifactPoolIds`
- `encyclopediaEntryIds`
- `bossRecordIds`
- `trainingScenarioIds`
- `cosmeticUnlockIds`
- `partyChronicleIds`
- `postRunSuggestionHistory`

`ProfileState`는 공격력, 구조물 체력, 마나 회복량, 웨이브 보상 배율을 직접 올리는 값을 갖지 않습니다.

전투 중 저장은 적 위치, 투사체, 상태이상, 경로, 보스 패턴, 겹친 웨이브 상태까지 저장해야 하므로 후순위입니다.

## 재접속과 세션 상태

런 밸런스 기준과 현재 접속 상태를 분리합니다.

저장되는 런 기준:

- playerCountAtStart
- activeDirections
- scalingProfileId
- 플레이어별 직업과 덱

세션에서만 바뀌는 값:

- 현재 접속 중인 플레이어
- 일시 이탈 상태
- 입력 지연
- 호스트 이전 여부

재접속 처리:

1. 저장된 RunState를 읽습니다.
2. 현재 접속 플레이어를 세션 상태에 붙입니다.
3. 해당 플레이어의 직업, 덱, 손패, 자원을 복구합니다.
4. 진행 중 투표가 있으면 남은 시간으로 합류합니다.
5. activeDirections와 scalingProfileId는 다시 계산하지 않습니다.

이탈자가 생겨도 비활성 방향을 닫거나 적 수를 즉시 줄이지 않습니다.

MVP에서는 전투 중 인원 변화에 따른 실시간 리밸런싱을 하지 않습니다.

### 중단/재개 데이터 흐름

중단과 재개는 `session_resume_flow`로 관리합니다.

```text
SessionInterruptDetected
-> SessionState.interruptState 갱신
-> PlayerRoleReservation 생성
-> 개인 카드/마나 입력 잠금
-> ResumeSnapshot 생성
-> 복귀 플레이어에게 Snapshot 전달
-> SessionResumeConfirmed
```

이 흐름은 `RunState`를 수정하지 않습니다.

수정 가능한 값:

- `connectedPlayerIds`
- `reservedRoles`
- `interruptState`
- `resumeSnapshotId`
- `pendingVoteId`
- `hostPlayerId`

수정 금지 값:

- `playerCountAtStart`
- `activeDirections`
- `scalingProfileId`
- 런 시드
- 이미 생성된 `WaveSpawnPlan.directions`

MVP의 보류 모드는 AI 조작이 아닙니다.

보류된 직업의 구조물은 계속 작동하지만, 카드 자동 사용, 마나 자동 소비, 보상 자동 선택은 실행하지 않습니다.

## 랜덤성

랜덤은 런 시드 기반으로 관리합니다.

랜덤을 쓰는 곳:

- 카드 보상 후보
- 상점 항목
- 이벤트 등장
- 웨이브 변형
- WaveSpawnPlan의 방향 대체
- 아티팩트 후보

랜덤을 쓰지 않는 곳:

- 기본 웨이브 보상 총량
- 웨이브 겹치기 보상
- 길막 판정
- 기지 피해
- playerCountAtStart
- activeDirections
- scalingProfileId

동일한 시드와 동일한 입력이면 같은 결과가 나오는 것이 이상적입니다.

## 멀티플레이 고려

MVP는 로컬 또는 단일 세션 검증을 우선합니다.

하지만 구조는 멀티 확장을 막지 않게 잡습니다.

권장:

- 입력은 명령으로 큐잉
- 시뮬레이션 상태는 권위 서버 또는 호스트가 소유
- 클라이언트는 예측보다 명확한 피드백 우선
- 투표는 VoteSystem에서만 처리
- 파티 자원 사용은 반드시 투표 이벤트를 거침

멀티에서 중요한 것:

- 웨이브 겹치기 투표 지연이 전투를 망치지 않아야 합니다.
- 카드 사용 지연이 너무 크면 액션성이 사라집니다.
- 경로 재계산 결과는 모든 클라이언트가 같아야 합니다.
- activeDirections와 WaveSpawnPlan은 호스트 또는 서버가 확정한 값을 그대로 동기화합니다.
- 클라이언트가 현재 접속 인원 기준으로 방향이나 스케일링을 다시 계산하면 안 됩니다.

## 성능 주의점

성능 위험:

- 적 수가 많을 때 매 프레임 경로 재계산
- 광역 피해가 많은 적을 매번 전체 검색
- 오라 중첩을 매 틱 전체 구조물에 재계산
- UI 경로 미리보기가 너무 자주 갱신

대응:

- 경로 재계산 요청 큐 사용
- 공간 분할 또는 그리드 기반 범위 검색
- 오라 영향권 캐싱
- 배치 미리보기는 입력 변화가 있을 때만 갱신
- 사망/파괴 이벤트를 배치 처리

## 개발 디버그 도구

프로토타입에서 꼭 필요한 디버그 표시:

- playerCountAtStart
- activeDirections
- scalingProfileId
- CombatTuningProfile
- 현재 접속 인원
- 다음 WaveSpawnPlan
- WaveSpawnPlan 방향 대체 이유
- 타일 좌표
- 현재 경로 비용
- 적 경로
- 설치 가능/불가 영역
- 길막 판정 결과
- 구조물 체력
- 적 목표
- 도발 대상
- 웨이브 겹침 수
- 자원 게이지 변화
- 첫 적 접촉 시점
- 첫 구조물 피격/파괴 시점
- 첫 기지 피해 시점
- 경로 연장 시간
- 구조물 종류별 생존 시간
- 플레이어별 마나 획득과 드로우 발동
- 손패 막힘 시간
- 보스 부위 체력
- 이벤트 로그
- 텔레메트리 이벤트 미리보기

### 플레이테스트 대시보드 집계

TelemetrySystem은 원본 이벤트를 저장하고, 플레이테스트 종료 후 대시보드용 집계 데이터를 생성합니다.

대시보드는 런타임 전투 판정에 영향을 주지 않는 읽기 전용 도구입니다.

집계 흐름:

1. 원본 이벤트를 `runId` 기준으로 묶습니다.
2. `playerCountAtStart`, `activeDirections`, 실제 `directions`를 분리해 세그먼트를 만듭니다.
3. 전투, 정산, 상점, 이벤트, 웨이브 대기 시간을 활동 버킷으로 나눕니다.
4. 패널별 파생 지표와 위험 신호를 계산합니다.
5. 관찰자 메모를 관련 패널과 이벤트에 연결합니다.
6. 위험 신호를 다음 테스트 가설과 액션 큐 항목으로 저장합니다.

대시보드 집계는 개인 딜량 순위, 개인 처치 순위, 개인 실수 목록을 만들지 않습니다.

웨이브 겹치기 지표는 보상 효율이 아니라 대기 감소와 위험 상승 여부만 계산합니다.

액션 큐는 자동 패치 시스템이 아닙니다.

전투 수치, 보상, 카드 후보 수, 희귀도, 활성 방향을 직접 수정하지 않고 다음 빌드에서 검토할 항목만 남깁니다.

디버그 도구는 밸런스 조정보다 먼저 만들어야 합니다.

보이지 않는 시스템은 조정할 수 없습니다.

## 구현 금지선

아래 구현은 하지 않습니다.

- 시간 경과 마나 자동 회복
- 웨이브 겹치기 보상 배율
- 웨이브 겹치기 희귀도 보정
- 완전 길막 허용
- 마지막 타격 자원 독식
- UI에서만 처리되는 핵심 전투 판정
- 현재 접속 인원으로 activeDirections 재계산
- 웨이브 겹치기로 비활성 방향 열기
- EnemySystem에서 임의 방향 스폰

이 금지선을 어기는 구현은 기획 의도를 깨뜨릴 가능성이 높습니다.
