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

## 엔진 선택 기준

이 문서는 엔진을 고정하지 않습니다.

다만 첫 코드 프로젝트는 아래 조건을 만족하는 쪽을 고릅니다.

| 기준 | 이유 |
| --- | --- |
| 2D 타일 맵 제작이 빠름 | M0의 핵심은 경로와 배치입니다. |
| 경로 탐색을 직접 제어 가능 | 완전 길막, 우회, 파괴 후 재계산을 검증해야 합니다. |
| 많은 단순 적 이동을 가볍게 처리 | 웨이브 밀도를 빨리 시험해야 합니다. |
| UI 작업이 빠름 | M0에서는 경로선, 체력, 디버그 로그가 필요하고, 이후에는 카드 UI가 필요합니다. |
| 데이터 파일을 쉽게 읽음 | 웨이브, 적, 구조물 수치를 빠르게 바꿔야 합니다. |

첫 선택에서 중요하지 않은 것:

- 최종 그래픽 품질
- 온라인 멀티 내장 기능
- 컷신 제작 편의성
- 에셋 스토어 규모
- 복잡한 물리 엔진

M0는 기술 쇼케이스가 아니라 전투 루프 검증입니다.

### M0 선택 컷라인

첫 엔진 선택은 아래를 통과하면 충분합니다.

- 빈 21x21 맵을 빠르게 표시할 수 있습니다.
- 타일 클릭과 배치 미리보기를 만들 수 있습니다.
- 경로 탐색을 라이브러리나 직접 코드로 제어할 수 있습니다.
- 디버그 버튼과 로그를 쉽게 붙일 수 있습니다.
- 테스트 데이터를 코드 밖으로 뺄 수 있습니다.

반대로 아래 이유만으로 엔진을 고르지 않습니다.

- 언젠가 온라인 멀티가 쉬워 보입니다.
- 고품질 3D 연출이 좋습니다.
- 에셋 스토어가 큽니다.
- 최종 카드 UI가 예쁘게 나올 것 같습니다.

M0 선택에서 후보가 비슷하면 익숙한 도구를 고르고 바로 프로젝트 뼈대를 만듭니다.

### M0 엔진 후보 해석

M0 후보는 아래 둘로 제한합니다.

| 후보 | 강점 | 주의 |
| --- | --- | --- |
| Godot | 2D 타일맵, 격자 경로 탐색, 독립 실행 빌드로 이어가기 쉽습니다. | 브라우저 공유보다 로컬 실행 확인을 먼저 봅니다. |
| Phaser/TypeScript | 브라우저 실행, 타일맵, 포인터 입력, 디버그 화면 반복이 빠릅니다. | 장기 독립 실행 게임 구조는 나중에 다시 판단해야 합니다. |

기본 선택은 Godot입니다.

M0를 여러 사람에게 링크로 빠르게 공유해야 한다면 Phaser/TypeScript를 선택합니다.

### Godot M0 장면 경계

Godot 기본 선택 시 첫 장면은 아래 경계만 사용합니다.

```text
Main
-> M0TestScene
   -> MapLayer
   -> CombatRoot
   -> HUDLayer
   -> DebugPanel
```

| 경계 | 책임 |
| --- | --- |
| `MapLayer` | 테스트 맵, 타일 좌표, 입구, 기지 위치 표시 |
| `CombatRoot` | 적, 구조물, 경로선 표시 |
| `HUDLayer` | 기지 체력, 웨이브 상태, 활성 방향, 배치 버튼 |
| `DebugPanel` | M0 전용 플레이어 수 변경, 시작, 리셋, 로그 |

전투 판정은 장면 노드가 아니라 시뮬레이션 코드에서 처리합니다.

첫 장면에는 로비, 상점, 보스, 저장, 카드 보상 화면을 붙이지 않습니다.

### Godot M0 첫 파일 경계

첫 파일 구조는 아래 범위에서 멈춥니다.

```text
project.godot
scenes/main/Main.tscn
scenes/m0/M0TestScene.tscn
scripts/m0/M0TestController.gd
scripts/m0/M0CombatSimulation.gd
scripts/m0/M0DebugLog.gd
data/m0/m0_test_data.json
```

`M0TestController.gd`는 입력을 받아 시뮬레이션 명령으로 넘기는 역할만 합니다.

`M0CombatSimulation.gd`는 M0가 끝날 때까지 임시 구현이어도 되지만, 화면 버튼을 직접 만들지 않습니다.

`m0_test_data.json`에는 맵, 적, 타워, 바리케이드, 웨이브, 기지 임시값만 둡니다.

첫 파일 구조에는 카드, 상점, 보스, 저장, 온라인, 아티팩트 폴더를 만들지 않습니다.

### M0 테스트 데이터 모양

`m0_test_data.json`의 최상위 키는 아래로 시작합니다.

```text
map
activeDirectionsByPlayerCount
base
structures
enemies
wave
debug
```

이 파일은 수치 밸런스의 정답이 아니라 첫 실행용 임시 데이터입니다.

시뮬레이션 코드는 이 키를 읽어 M0 화면을 만들고, 누락된 키가 있으면 DebugPanel에 로드 실패를 남깁니다.

첫 데이터 모양에는 카드, 보상, 골드, 상점, 보스, 아티팩트 키를 추가하지 않습니다.

### Godot M0 첫 커밋 신호

첫 커밋은 아래 신호까지만 확인합니다.

```text
project.godot 열림
-> Main 실행
-> M0TestScene 표시
-> m0_test_data.json 로드
-> DebugPanel 로그 출력
-> 기본 버튼 입력 로그 출력
```

첫 커밋에서는 `Pathfinding`, `EnemySystem`, `StructureSystem`이 실제 전투 판정을 끝낼 필요가 없습니다.

대신 이후 구현이 붙을 자리가 화면에 보이고, 데이터 로드와 디버그 로그가 작동해야 합니다.

### Godot M0 첫 구현 중단선

첫 구현은 아래 순서의 중단선을 사용합니다.

```text
ProjectOpen
-> SceneVisible
-> DataLoadLogged
-> DebugInputLogged
-> CombatWorkStarts
```

`CombatWorkStarts` 전에는 적 이동, 경로 탐색, 구조물 파괴를 시작하지 않습니다.

각 중단선은 DebugPanel 로그나 화면 상태로 확인할 수 있어야 합니다.

### Godot M0 환경 경계

M0 프로젝트는 현재 저장소 루트를 Godot 프로젝트 루트로 사용합니다.

첫 생성 시에는 아래를 만들지 않습니다.

- `addons`
- 외부 에셋 팩
- 온라인 SDK 설정
- 저장/세이브 플러그인
- 카드 UI 전용 테마

첫 실행은 `Main.tscn`에서 `M0TestScene`으로 바로 들어가며, 그래픽은 기본 도형과 텍스트만 사용합니다.

환경 문제가 생기면 전투 코드를 늘리지 않고, 프로젝트 열림과 첫 장면 실행부터 복구합니다.

### Godot M0 생성 순서

생성 작업은 아래 순서로만 진행합니다.

```text
CreateProjectFile
-> CreateMinimalFolders
-> CreateMainScene
-> CreateM0TestScene
-> CreateM0DataFile
-> ConnectDebugPanel
-> RunMainScene
```

`RunMainScene` 전에는 `Pathfinding`, `EnemySystem`, `StructureSystem` 구현을 시작하지 않습니다.

`CreateMinimalFolders`는 `scenes/main`, `scenes/m0`, `scripts/m0`, `data/m0`까지만 허용합니다.

### M0 빌드 모드 전환

아래 신호가 모두 있으면 기술 문서 확장을 멈추고 파일 생성으로 넘어갑니다.

```text
EngineChosenGodot
ProjectRootConfirmed
FirstFilesLocked
M0DataShapeLocked
CreateOrderLocked
FirstRunCheckLocked
```

빌드 모드에서는 문서보다 실행 상태를 우선합니다.

Godot가 열리지 않음, `Main.tscn` 실행 실패, `m0_test_data.json` 로드 실패가 있을 때만 문서를 다시 조정합니다.

그 외에는 `project.godot`와 첫 장면 파일 생성을 먼저 합니다.

### M0 첫 빌드 화면 경계

첫 빌드는 아래 UI 영역만 가집니다.

| 영역 | 책임 |
| --- | --- |
| HeaderBar | 기지 체력, 웨이브 상태, 현재 플레이어 수 표시 |
| MapViewport | 21x21 맵, 중앙 기지, 활성 침공 방향 표시 |
| ActionBar | 타워 배치 모드, 바리케이드 배치 모드, 웨이브 시작, 리셋 입력 |
| DebugPanel | 데이터 로드, 버튼 입력, 방향 변경 로그 |

첫 빌드에서는 ActionBar 입력을 DebugPanel 로그로 확인하는 데 그쳐도 됩니다.

카드 손패, 마나 바, 보상 선택, 상점, 보스 연출, 저장 메뉴는 연결하지 않습니다.

### M0 첫 개발 세션 컷라인

첫 개발 세션은 아래 흐름까지만 진행합니다.

```text
CreateProject
-> RunMain
-> ShowM0Layout
-> LoadM0Data
-> LogDebugInputs
-> StopSession
```

`StopSession` 전에는 `Pathfinding`, `EnemySystem`, `StructureSystem`을 연결하지 않습니다.

이 컷라인을 통과한 다음 세션에서 `MapGrid`와 활성 방향 표시를 실제 데이터에 묶기 시작합니다.

### M0 첫 실행 확인 순서

첫 실행 확인은 아래 순서를 고정합니다.

```text
OpenProject
-> RunMainScene
-> CheckM0Layout
-> CheckDataLoadLog
-> CheckDebugInputLog
-> EndFirstRunCheck
```

`EndFirstRunCheck` 전에는 `MapGrid` 경로 계산, 적 스폰, 구조물 설치를 연결하지 않습니다.

실패가 있으면 실패한 단계의 파일만 수정하고 같은 확인 순서를 다시 실행합니다.

### M0 두 번째 개발 세션 경계

첫 실행 확인을 통과한 다음에는 데이터 표시만 연결합니다.

```text
ReadM0MapData
-> DrawGrid
-> DrawBaseMarker
-> DrawEntranceMarkers
-> ApplyDebugPlayerCount
-> LogActiveDirections
-> StopSecondSession
```

`StopSecondSession` 전에는 경로 계산, 적 생성, 구조물 설치 검증을 연결하지 않습니다.

이 세션의 출력은 화면 표시와 DebugPanel 로그뿐입니다.

### M0 세 번째 개발 세션 경계

세 번째 개발 세션은 타일 입력을 화면과 로그로 확인하는 단계입니다.

```text
SelectBuildMode
-> HighlightHoveredTile
-> LogClickedTile
-> ShowPlacementPreview
-> ShowBasicRejectColor
-> StopThirdSession
```

`StopThirdSession` 전에는 `BuildStructureCommand`, `Pathfinding`, `EnemySystem`, 구조물 체력을 연결하지 않습니다.

이 세션의 출력은 선택 모드, 타일 좌표, 미리보기, 기본 거절 색상, DebugPanel 로그뿐입니다.

### M0 네 번째 개발 세션 경계

네 번째 개발 세션은 전투 구조물이 아니라 화면 마커를 만듭니다.

```text
ConfirmPreviewTile
-> CreateStructureMarker
-> StoreOccupiedTile
-> RejectOccupiedOrBlockedMarker
-> ResetStructureMarkers
-> LogPlacementState
-> StopFourthSession
```

`StopFourthSession` 전에는 `Pathfinding`, `EnemySystem`, 구조물 체력, 공격 대상, 설치 비용을 연결하지 않습니다.

이 세션의 구조물 데이터는 `type`, `tile`, `markerId` 정도만 가집니다.

### M0 다섯 번째 개발 세션 경계

다섯 번째 개발 세션은 경로 표시와 완전 길막 거절만 연결합니다.

```text
CalculateActiveEntrancePaths
-> DrawPathLines
-> RecalculatePathAfterMarker
-> RejectFullBlockPlacement
-> LogPathRejectReason
-> ResetPathPreview
-> StopFifthSession
```

`StopFifthSession` 전에는 `EnemySystem`, 구조물 체력, 공격, 파괴, 설치 비용, 마나를 연결하지 않습니다.

이 세션의 경로 계산은 화면 경로선과 배치 거절에만 사용합니다.

### M0 여섯 번째 개발 세션 경계

여섯 번째 개발 세션은 실제 적 시스템이 아니라 스폰 마커 표시만 연결합니다.

```text
StartDebugWave
-> ReadActiveEntrances
-> CreateEnemySpawnMarkers
-> SkipInactiveEntrances
-> LogSpawnMarkers
-> ResetEnemySpawnMarkers
-> StopSixthSession
```

`StopSixthSession` 전에는 적 이동, 적 체력, 구조물 공격, 기지 피해, 처치, 마나 획득을 연결하지 않습니다.

이 세션의 적 데이터는 `enemyId`, `direction`, `tile`, `markerId` 정도만 가집니다.

### M0 일곱 번째 개발 세션 경계

일곱 번째 개발 세션은 적 마커 이동만 연결합니다.

```text
StartMarkerMovement
-> FollowCurrentPathLine
-> KeepSpawnDirection
-> ReactToPathLineChanged
-> LogMarkerReachedBase
-> ResetMarkerMovement
-> StopSeventhSession
```

`StopSeventhSession` 전에는 적 체력, 구조물 공격, 구조물 충돌, 기지 피해, 처치, 마나 획득을 연결하지 않습니다.

이 세션의 이동 상태는 `markerId`, `pathIndex`, `pathProgress`, `isMoving` 정도만 가집니다.

## 상위 모듈

| 모듈 | 역할 |
| --- | --- |
| GameSession | 런 전체 상태, 일자, 계절, 승패, 저장, 런 시작 고정값 |
| NewRunSetupFlow | 참고 메모, 방향 미리보기, 런 길이, 직업 선택, 파티 의도 확인 |
| RunConfigBuilder | 로비 설정을 RunState로 확정 |
| RunConfigLockSnapshotStore | 시작 순간의 확정값을 저장하고 이후 변경을 차단 |
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
| ArtifactSystem | 아티팩트 장착 슬롯, 휴면 보관함, 전역 효과, 부작용 |
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

### M0 실행 흐름

첫 구현은 아래 흐름이 한 번 끊기지 않고 도는지만 확인합니다.

```text
RunState 생성
-> MapGrid 생성
-> WaveSpawnPlan 1개 생성
-> EnemySystem 스폰
-> Pathfinding 경로 계산
-> BuildStructureCommand 처리
-> 경로 재계산
-> 적 이동과 구조물 공격
-> StructureDestroyedEvent
-> 경로 재계산
-> 기지 피해 또는 웨이브 종료
```

M0에서는 `CardSystem`, `ShopSystem`, `BossSystem`, `ArtifactSystem`이 없어도 됩니다.

단, 이 흐름에서 나온 이벤트는 이후 시스템이 붙을 수 있도록 `StructureBuiltEvent`, `StructureDestroyedEvent`, `BaseDamagedEvent`, `WaveCompletedEvent`처럼 이름이 있는 이벤트로 남깁니다.

### M0 첫 주 제외 모듈

첫 주 구현에서 아래 모듈은 껍데기나 더미 데이터로 충분합니다.

| 모듈 | 첫 주 처리 |
| --- | --- |
| CardSystem | 없음. 구조물 배치는 임시 버튼이나 단축키로 처리합니다. |
| ResourceSystem | 없음. 설치 비용은 임시로 무료입니다. |
| WaveSystem | 웨이브 1개를 고정 생성합니다. |
| BossSystem | 제외합니다. |
| ShopSystem | 제외합니다. |
| ArtifactSystem | 제외합니다. |

첫 주의 기술 위험은 경로 재계산과 구조물 파괴 이벤트입니다.

### M0 임시 입력

M0 입력은 카드 사용이 아니라 테스트 명령입니다.

| 입력 | 생성 명령 |
| --- | --- |
| 플레이어 수 변경 | `SetDebugPlayerCountCommand` |
| 타워 배치 모드 | `SelectBuildModeCommand(tower)` |
| 바리케이드 배치 모드 | `SelectBuildModeCommand(barricade)` |
| 타일 클릭 | `BuildStructureCommand` 또는 거절 표시 |
| 웨이브 시작 | `StartDebugWaveCommand` |
| 리셋 | `ResetM0SceneCommand` |

`SetDebugPlayerCountCommand`는 M0 테스트 화면에서만 허용합니다.

정식 런에서는 `playerCountAtStart`가 런 시작 순간 고정되며, 전투 중 디버그 입력으로 바뀌지 않습니다.

### M0 테스트 데이터 경계

M0 데이터는 정식 콘텐츠가 아니라 첫 화면을 움직이기 위한 시드 데이터입니다.

| 데이터 ID | 소유 모듈 | 필요한 필드 |
| --- | --- | --- |
| `m0_test_map` | MapGrid | 크기, 기지 좌표, 입구 좌표, 설치 가능 타일 |
| `m0_walker` | EnemySystem | 이동 속도, 체력, 구조물 공격, 기지 피해 |
| `m0_basic_tower` | StructureSystem | 설치 가능 여부, 체력, 사거리, 피해 |
| `m0_barricade` | StructureSystem | 설치 가능 여부, 체력, 경로 차단 여부 |
| `m0_wave_001` | WaveSystem | 사용할 적 ID, 활성 방향 필터, 스폰 간격 |
| `m0_base` | GameSession | 최대 체력, 현재 체력, 실패 조건 |

M0 데이터 파일은 정식 런 데이터와 분리해도 됩니다.

중요한 것은 이후 정식 데이터로 교체하기 쉽도록 같은 로더나 같은 형태의 데이터 구조를 사용하는 것입니다.

M0 데이터에는 카드 비용, 보상, 골드, 희귀도, 계절, 보스 태그를 넣지 않습니다.

### M0 코드 경계

첫 코드 구조는 엔진보다 아래 경계를 먼저 지킵니다.

```text
M0 시작
-> M0 데이터 로드
-> 시뮬레이션 상태 생성
-> 입력을 명령으로 변환
-> 시뮬레이션 갱신
-> 화면 표시
-> 디버그 로그 기록
```

권장 경계:

| 경계 | 역할 | 금지 |
| --- | --- | --- |
| 데이터 | M0 맵, 적, 구조물, 웨이브 값을 제공합니다. | 화면 코드 안에 수치를 직접 박지 않습니다. |
| 시뮬레이션 | 경로, 이동, 공격, 파괴, 종료를 계산합니다. | UI 버튼을 직접 만들지 않습니다. |
| 화면 | 상태를 읽고 맵, 체력, 경로선, 로그를 보여줍니다. | 전투 판정을 직접 바꾸지 않습니다. |
| 디버그 | M0 전용 조작과 로그를 제공합니다. | 정식 런 규칙을 덮어쓰지 않습니다. |

M0에서는 이 경계만 지키면 충분하며, 저장/온라인/카드/상점/보스용 구조를 미리 만들 필요는 없습니다.

### M0 구현 순서

기술 작업은 세로 한 조각이 먼저 돌아가게 만듭니다.

```text
실행 가능한 빈 화면
-> M0 데이터 로드
-> 맵/기지/활성 방향 표시
-> 배치 명령과 길막 검증
-> 적 스폰과 이동
-> 구조물 공격/파괴
-> 경로 재계산
-> 기지 피해 또는 웨이브 종료 로그
```

각 단계는 임시 그래픽과 임시 수치로 통과해도 됩니다.

다만 이전 단계가 실행되지 않으면 다음 큰 시스템을 붙이지 않습니다.

### M0 완료 신호

M0 완료 판정은 새 기능 수가 아니라 반복 실행 안정성으로 봅니다.

최소 확인 신호:

- `StructureBuiltEvent`
- `StructureDestroyedEvent`
- `BaseDamagedEvent` 또는 `WaveCompletedEvent`
- 활성 방향 변경 후 생성된 `WaveSpawnPlan`
- 완전 길막 거절 로그

위 신호가 한 웨이브 안에서 확인되고, 같은 빌드를 3회 반복해도 끊기지 않으면 M0를 통과로 봅니다.

### M0 이후 카드/마나 연결

M0 통과 후 `CardSystem`과 `ResourceSystem`은 기존 전투 명령을 감싸는 얇은 입력 계층으로 먼저 붙입니다.

```text
카드 선택
-> 비용과 대상 검증
-> BuildStructureCommand 생성
-> StructureSystem 처리
-> EnemyKilledEvent
-> ResourceSystem 게이지 갱신
-> 손패/마나 표시 갱신
```

이 단계에서 카드 효과는 새 전투 규칙을 만들지 않고, M0에서 이미 검증한 구조물 배치와 자원 표시만 연결합니다.

카드 보상, 희귀도, 상점, 강화, 아티팩트 효과는 연결하지 않습니다.

### M0 개발 착수 신호

아래가 모두 결정되면 기술 설계를 더 늘리지 않고 프로젝트를 생성합니다.

- 사용할 엔진이나 프레임워크
- M0 테스트 화면을 첫 진입 화면으로 쓰는 것
- `m0_*` 테스트 데이터만 읽는 첫 데이터 범위
- 데이터, 시뮬레이션, 화면, 디버그의 책임 경계
- 빈 화면부터 종료 로그까지의 구현 순서
- M0 완료 신호와 아이디어 보류 규칙

이 신호가 충족된 뒤에는 저장, 온라인, 카드 보상, 상점, 보스, 아티팩트 구조를 먼저 만들지 않습니다.

## 런 시작 데이터 흐름

런 시작은 전투보다 먼저 확정되는 단계입니다.

```text
Lobby Selection
-> NewRunSetupFlow
-> SetupSuggestionSlot 최대 2개 표시
-> LobbyDirectionPreset 미리보기
-> RunConfig
-> RunConfigBuilder
-> playerCountAtStart 확정
-> ScalingSystem에서 activeDirections와 scalingProfileId 조회
-> RunConfigLockSnapshot 저장
-> RunState 생성
-> 첫 WaveSpawnPlan 생성
-> GameSession 시작
```

중요:

- `SetupSuggestionSlot`은 UI 참고 메모이며 직업, 시작 덱, 아티팩트, 활성 방향, 보상, 희귀도, 카드 후보 수를 바꾸지 않습니다.
- `LobbyDirectionPreset`은 시작 전 미리보기 전용이며, 인원이 바뀌면 준비 완료 상태를 해제하고 다시 확인합니다.
- `playerCountAtStart`는 로비에서 런을 시작하는 순간 고정합니다.
- `activeDirections`는 `playerCountAtStart`로 한 번만 계산합니다.
- `scalingProfileId`도 런 시작 시 고정합니다.
- `RunConfigLockSnapshot`은 `playerCountAtStart`, `activeDirections`, `scalingProfileId`, `seed`, `selectedMode`, `classIdsByPlayer`를 불변값으로 저장합니다.
- 현재 접속 인원은 세션 상태일 뿐, 런 밸런스 기준이 아닙니다.

런 시작 이후에는 플레이어가 나가거나 재접속해도 위 세 값은 바뀌지 않습니다.

### 새 런 준비 상태 경계

새 런 준비 화면은 플레이어가 판단할 정보를 정리하지만, 자동 빌드를 만들지 않습니다.

| 데이터 | 쓰기 시점 | 변경 가능 범위 |
| --- | --- | --- |
| `SetupSuggestionSlot` | 결과/메타/도감/훈련장에서 로비로 들어올 때 | 고정, 접기, 삭제만 가능 |
| `LobbyDirectionPreset` | 로비 인원 변화 시 | 시작 전 미리보기만 갱신 |
| `PartyIntentNote` | 준비 완료 전 | 한 줄 메모 작성, 수정, 비우기 |
| `RunConfigLockSnapshot` | 시작 버튼 확정 시 | 생성 이후 변경 불가 |

`RunConfigBuilder`는 위 데이터를 읽어 `RunState`를 만들지만, 제안 메모나 역할 힌트를 근거로 직업, 카드, 아티팩트, 활성 방향을 자동 선택하지 않습니다.

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
| ReplaceArtifactCommand | 장착 아티팩트 휴면 처리와 새 아티팩트 장착 |
| ReactivateDormantArtifactCommand | 휴면 아티팩트 재장착 |
| ReleaseDormantArtifactCommand | 휴면 보관함 초과 시 아티팩트 방출 |
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
| ArtifactDormantEvent | 아티팩트 휴면 처리 |
| ArtifactReactivatedEvent | 휴면 아티팩트 재장착 |
| ArtifactSideEffectTriggeredEvent | 아티팩트 부작용 발동 |
| ShopSessionStartedEvent | 상점 세션 시작 |
| ShopPurchaseEvent | 상점 구매 완료 |
| BaseDamagedEvent | 기지 피해 |
| RunFailedEvent | 런 실패 |

## 아티팩트 시스템 경계

`ArtifactSystem`은 장착 효과와 휴면 보관함을 함께 관리하지만, 보상 생성이나 웨이브 스폰을 직접 만들지 않습니다.

| 상태 | 설명 |
| --- | --- |
| `equippedArtifactIds` | 효과와 부작용이 켜진 아티팩트 |
| `dormantArtifactIds` | 효과가 꺼진 보관 아티팩트 |
| `releasedArtifactIds` | 이번 런에서 방출한 아티팩트 |
| `currentSlotLimit` | 기본 3, 장착 효과 포함 최대 4 |
| `activeSideEffectProfileIds` | 현재 전투/상점/HUD에서 읽을 부작용 |

다른 시스템이 읽는 값:

| 시스템 | 읽는 값 | 금지 |
| --- | --- | --- |
| WaveScheduler | 장착 아티팩트의 `stackLimitModifier` | 휴면 아티팩트로 겹치기 한도 증가 |
| ResourceSystem | 장착 아티팩트의 자원 관련 효과 | 시간 경과 마나 회복 생성 |
| ShopSystem | 장착 아티팩트의 상점 부작용 | 휴면 아티팩트 비용 적용 |
| Presentation | 장착/휴면 상태와 부작용 문구 | 휴면 효과를 활성 효과처럼 표시 |

아티팩트 교체, 재장착, 방출은 모두 명령과 투표를 거쳐 처리합니다.

전투 중에는 `ReplaceArtifactCommand`, `ReactivateDormantArtifactCommand`, `ReleaseDormantArtifactCommand`를 받을 수 없습니다.

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
- 휴면 아티팩트와 방출된 아티팩트
- 현재 아티팩트 슬롯 한도와 휴면 보관함 한도
- 활성 아티팩트 부작용 프로필
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
- `favoritePartyChronicleIds`
- `hiddenPartyChronicleIds`
- `lastChronicleFilterState`
- `postRunSuggestionHistory`

`ProfileState`는 공격력, 구조물 체력, 마나 회복량, 웨이브 보상 배율을 직접 올리는 값을 갖지 않습니다.

### 파티 연대기 저장 구조

파티 연대기는 런 저장이 아니라 프로필 기록입니다.

저장 흐름:

1. 100일 결과 회고가 `FinalResultReflection`을 확정합니다.
2. 마지막 패널에서 저장을 누르면 `PartyChronicleEntry`를 생성합니다.
3. `PartyChronicleEntry.sourceResultId`로 원본 결과를 참조합니다.
4. 생성된 `partyChronicleId`를 `ProfileState.partyChronicleIds`에 추가합니다.
5. 즐겨찾기와 숨김은 원본 연대기 데이터를 바꾸지 않고 `favoritePartyChronicleIds`, `hiddenPartyChronicleIds`로 분리합니다.

`PartyChronicleEntry`에 저장할 것:

- 결과, 도달 일자, 시작 인원수, 활성 방향
- 파티 직업 조합과 장착 아티팩트
- 최종 킬존, 최종 방어선 이전 횟수, 오래 버틴 구조물
- 결정적 장면 유형 최대 3개
- 95일에 살린 축과 포기한 약점
- 기억 태그 3~5개와 다음 런 메모 최대 2개
- 선택한 제목 후보 또는 짧게 수정한 제목

기억 태그는 `PartyChronicleMemoryTagProfile.id`만 저장합니다.

태그 라벨과 설명은 콘텐츠 데이터와 현지화 파일에서 읽으며, 저장된 연대기 안에 라벨 문자열을 복사하지 않습니다.

태그 사전이 확장되어도 기존 `memoryTagIds`는 같은 의미를 유지해야 하며, 삭제 대신 숨김 또는 병합 매핑을 사용합니다.

`PartyChronicleEntry`에 저장하지 않을 것:

- 개인 딜량, 개인 처치 수, 개인 실수 소유자
- MVP, 캐리, 기여도 순위, 리더보드 순위
- 승률, 최고 점수, 평균 점수
- 웨이브 겹치기 보상 효율, 보상 배율, 희귀도 효율
- 비활성 방향의 위험, 붕괴, 보강 추천 상태

### 훈련장 샌드박스 상태

훈련 장면은 `TrainingSandboxState`로 실행합니다.

`TrainingSandboxState`는 `RunState`를 복사하지 않고, `TrainingScenarioProfile`의 작은 전장, 고정 손패, 고정 적 묶음만 읽습니다.

입력:

- `trainingScenarioId`
- `profileId`
- `sourceRunId` 또는 `sourceResultId`
- `targetLearningTag`
- `activeDirectionProjection`
- `trainingHandProfileId`

수정 가능한 값:

- 훈련 전장 안의 임시 구조물
- 훈련 손패의 임시 카드 상태
- 훈련 적 위치와 체력
- 사용한 대응 태그
- 힌트 단계

수정 금지 값:

- 실제 런 덱, 손패, 버린 카드 더미
- 실제 골드, 보스 파편, 아티팩트
- 실제 기지 체력과 구조물 기록
- 실제 `activeDirections`, `scalingProfileId`, `WaveSpawnPlan`
- 보상 후보 수, 희귀도, 난이도

훈련이 끝나면 `training_scenario_completed`만 기록하고, 다음 런에는 메모나 즐겨찾기만 전달합니다.

### 알파 직업 커버리지 러너 상태

`AlphaClassCoverageRunner`는 실제 플레이어를 대체하지 않고, 알파 테스트 전 기능 파손을 찾는 자동 스모크 테스트입니다.

입력:

- `coverageScenarioId`
- `classId`
- `fixedMapId`
- `fixedHandProfileId`
- `fixedWaveProfileId`
- `scriptedInputProfileId`

출력:

- `coverageRunId`
- `classId`
- `passed`
- `failedStepId`
- `requiredSignalIds`
- `missingSignalIds`
- `rejectReasonIds`

필수 신호:

| 직업 | 신호 |
| --- | --- |
| 수호자 | `taunt_applied`, `guardian_hit_received`, `thorns_or_guard_log` |
| 건축가 | `path_changed`, `full_block_rejected`, `barricade_break_or_debris_log` |
| 원소술사 | `splash_damage_applied`, `control_effect_applied`, `invalid_target_rejected` |
| 땜장이 | `aura_applied`, `repair_or_boost_applied`, `invalid_target_rejected` |

금지:

- 승률 기반 밸런스 판정
- 정답 빌드 추천
- 카드 자동 조정
- 보상, 희귀도, 상점 가격 자동 변경
- 실제 알파 테스트 대체

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
