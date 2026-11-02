# Dev Workstation 구축 결과

Docker 기반 정적 웹 서버를 빌드하고 실행한 개발 워크스테이션 구축 기록입니다. 명령은 저장소 루트 `C:\dev\dev-workstation`에서 실행합니다. Docker Desktop이 실행 중이어야 하며, 필요한 이미지가 없으면 Docker Hub 접근이 필요합니다.

## 제출 증거 요약

| 목적 | 명령 / 확인 결과 | 증거 |
|---|---|---|
| Docker 버전 및 데몬 | `docker --version`, `docker info` (Context: `desktop-linux`) | [버전 로그](logs/docker-version.txt), [info 로그](logs/docker-info.txt) |
| 이미지 빌드 및 컨테이너 확인 | `docker build -t dev-workstation-web:1.0 .`, `docker images`, `docker ps -a` | 아래 빌드 로그, [이미지 목록](logs/docker-images.txt), [컨테이너 목록](logs/docker-ps-a.txt) |
| 웹 접속 및 바인드 마운트 | `http://localhost:8080`, `http://localhost:8081` | [포트 접속](screenshots/port-access.png), [변경 전](screenshots/bind-before.png), [변경 후](screenshots/bind-after.png) |
| 볼륨 영속성 | 쓰기 컨테이너 삭제 후 새 컨테이너에서 `volume persistence test` 읽기 | [볼륨 증거](screenshots/volume-proof.png) |
| 저장소 업로드 | `origin`은 `https://github.com/sunnybyeol/dev-workstation.git`, 최근 커밋 `5600415b4e9f818a088d6afb469284a4b2cddd09` | `git remote -v`, `git log -1`로 재확인 가능 |
| 권한 변경, hello-world | 아래 재현 절차 참조. 이 환경에서는 Docker 데몬 접근이 거부되어 아직 새 실행 로그를 만들지 못함 | 제출 전 실행 결과를 각각 `logs/permissions.txt`, `logs/hello-world.txt`에 저장해야 함 |

> 기존 증거 파일은 2026-11-02 평가 보완 작업 시점에 검토했습니다. 각 기록의 실제 실행 시각은 원본 로그에 없으므로 소급해 만들어 넣지 않았습니다. 새로 만드는 로그에는 실행 시각을 함께 기록하세요.

## 프로젝트 구조

```text
.
├── Dockerfile             # nginx 기반 이미지와 헬스체크 정의
├── app/index.html         # 바인드 마운트로 제공하는 페이지
├── site/index.html        # Dockerfile 빌드에 복사되는 페이지
├── logs/                  # 명령 출력 기록
├── screenshots/           # 브라우저 및 볼륨 증거
└── README.md              # 재현 절차와 결과 요약
```

## 이미지와 컨테이너

이미지는 Dockerfile과 파일을 바탕으로 만든 변경 불가 템플릿이며, 여기서는 `dev-workstation-web:1.0`이 nginx와 `site/index.html`을 담습니다. 컨테이너는 그 이미지로 실행한 독립 인스턴스입니다. 컨테이너를 실행해도 이미지 자체는 바뀌지 않고, 컨테이너 내부에서 한 변경은 해당 컨테이너를 삭제하면 사라질 수 있습니다. 여러 컨테이너를 같은 이미지에서 만들 수 있습니다.

## 빌드 및 웹 서버 실행

저장소 루트에서 실행합니다. Dockerfile의 `COPY site/ ...`가 `site/index.html`을 이미지에 넣습니다.

```powershell
Set-Location C:\dev\dev-workstation
docker build -t dev-workstation-web:1.0 .
docker images
docker run -d --name dev-web -p 8080:80 dev-workstation-web:1.0
docker ps -a
```

기존 `dev-web` 이름이 사용 중이면 먼저 확인합니다. 필요한 컨테이너인지 확인한 뒤에만 중지/삭제하세요.

```powershell
docker ps -a --filter "name=^/dev-web$"
docker stop dev-web
docker rm dev-web
```

빌드에 실패하면 저장소 루트에서 실행했는지, `Dockerfile`과 `site/index.html`이 있는지 확인한 뒤 전체 빌드 출력을 살펴보세요. 캐시 문제를 의심할 때는 다음처럼 다시 빌드할 수 있습니다.

```powershell
docker build --no-cache --progress=plain -t dev-workstation-web:1.0 .
```

빌드 로그에 오류가 있으면 마지막 오류뿐 아니라 그 직전 단계의 출력도 확인합니다. 이미지 목록과 컨테이너 목록은 서로 다른 시점의 기록일 수 있으므로, 새로 저장할 때 명령과 실행 시각을 같이 적으세요.

## 포트 매핑과 네트워크

접속 주소는 `http://localhost:8080`이며, `-p 8080:80`은 호스트의 8080 포트를 컨테이너의 80 포트에 연결합니다. 컨테이너는 기본적으로 별도의 네트워크 네임스페이스를 사용하므로 컨테이너 안의 포트가 호스트에 자동으로 공개되지 않습니다. Docker가 포트 게시 규칙을 설정하면 호스트 요청이 컨테이너의 80번 포트로 전달됩니다.

브라우저 증거 외에 HTTP 상태 코드도 확인할 수 있습니다.

```powershell
curl.exe -sS -o NUL -w "HTTP %{http_code}`n" http://localhost:8080
```

정상 응답은 `HTTP 200`입니다. 포트 충돌 시 `docker ps -a`로 컨테이너를 확인하고, Windows에서는 `Get-NetTCPConnection -LocalPort 8080` 또는 `netstat -ano | findstr :8080`으로 점유 프로세스를 찾을 수 있습니다. Linux/WSL에서는 `ss -ltnp` 또는 `lsof -i :8080`을 사용할 수 있습니다.

## 바인드 마운트

바인드 마운트는 호스트의 `app` 디렉터리를 컨테이너의 nginx 웹 루트에 읽기 전용으로 연결합니다. `Dockerfile` 빌드에는 `site`가 사용되고, 이 검증에서는 호스트의 `app`이 사용됩니다.

```powershell
docker run -d --name dev-web-bind -p 8081:80 -v "${PWD}/app:/usr/share/nginx/html:ro" nginx:alpine
```

Windows PowerShell, WSL, Linux/macOS는 경로 표기와 Docker Desktop 파일 공유 설정이 다릅니다. Windows 경로는 PowerShell의 `${PWD}`를 사용할 수 있고, WSL에서는 WSL 내부 경로(예: `/mnt/c/dev/dev-workstation/app`)를 사용하세요. 해당 경로가 Docker Desktop에서 공유/접근 가능한지도 확인합니다. 폴더를 옮기면 상대 경로 기준 디렉터리를 다시 확인하세요.

## 파일 권한 확인 증거 보완

Windows NTFS 권한과 Linux의 `rwx` 모드는 같은 표기가 아닙니다. Linux/WSL에서 다음을 실행하고 출력 전체를 `logs/permissions.txt`에 기록하세요. 아래 명령은 `app/index.html`의 소유자 읽기/쓰기, 그룹 및 기타 사용자 읽기 권한(644)을 설정하고 `ls -l`로 증명합니다.

```bash
cd /mnt/c/dev/dev-workstation
chmod 644 app/index.html
ls -l app/index.html
```

`rwx`는 각각 읽기(read), 쓰기(write), 실행(execute) 비트입니다. 숫자 표기는 읽기=4, 쓰기=2, 실행=1의 합을 소유자/그룹/기타 사용자 순서로 씁니다. 예를 들어 `755`는 소유자 `rwx`, 그룹과 기타 사용자는 `r-x`입니다. 일반 HTML 파일은 보통 실행 비트가 필요 없으므로 이 예제에서는 `644`를 사용합니다.

## hello-world 증거 보완

아래를 실행하고 명령과 전체 결과를 `logs/hello-world.txt`에 저장하세요. `Hello from Docker!`와 완료 안내가 출력되면 성공입니다.

```powershell
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
"# 실행 시각: $stamp`n# 목적: Docker 데몬 및 이미지 실행 확인`n> docker run --rm hello-world" | Set-Content logs/hello-world.txt
docker run --rm hello-world 2>&1 | Tee-Object -FilePath logs/hello-world.txt -Append
```

현재 확인 과정에서 `docker ps`가 `docker API ... dockerDesktopLinuxEngine` 파이프 접근 거부를 반환했습니다. 따라서 `hello-world`나 `chmod` 실행을 완료했다고 기록하지 않았습니다. Docker Desktop 데몬 연결이 복구된 뒤 위 명령을 실행해 실제 출력 파일을 갱신하세요.

## Docker 볼륨 영속성과 백업

볼륨은 컨테이너 생명주기와 분리된 Docker 관리 저장소입니다. 컨테이너 삭제만으로 볼륨 데이터가 지워지지는 않습니다. 볼륨을 지우기 전 백업하고, 복원 시 동일한 볼륨에 아카이브를 풀 수 있습니다.

```powershell
docker volume create dev-volume
docker run --rm -v dev-volume:/data alpine sh -c "echo 'volume persistence test' > /data/result.txt"
docker run --rm -v dev-volume:/data alpine cat /data/result.txt
# 백업 (현재 폴더에 dev-volume-backup.tgz 생성)
docker run --rm -v dev-volume:/data -v "${PWD}:/backup" alpine tar czf /backup/dev-volume-backup.tgz -C /data .
# 복원 (빈 대상 볼륨 권장)
docker volume create dev-volume-restore
docker run --rm -v dev-volume-restore:/data -v "${PWD}:/backup" alpine tar xzf /backup/dev-volume-backup.tgz -C /data
```

볼륨 백업 아카이브는 컨테이너와 별도 위치에 보관하세요. 이 예제는 복원 명령을 문서화한 절차이며 현재 복구 실행 증거를 뜻하지 않습니다.

## Docker 로그와 데몬 상태

`docker info`의 기존 기록은 [logs/docker-info.txt](logs/docker-info.txt)에 있습니다. 검토 시 클라이언트 버전 `29.9.2`, Context `desktop-linux`가 기록되어 있습니다. 데몬 연결 여부와 서버 버전, 저장소/런타임 상태는 `docker info`의 Server 섹션에서 확인합니다. 연결이 실패하면 데몬 상태를 확인할 수 없으므로 Docker Desktop을 시작하고 명령을 다시 실행합니다.

```powershell
docker info
docker logs dev-web
docker stats --no-stream
```

각 명령의 최신 출력은 [logs](logs/)에 저장합니다. 현재 `docker-logs.txt`는 비어 있으므로 최신 로그를 다시 캡처해야 합니다.

## Git 및 GitHub

저장소: <https://github.com/sunnybyeol/dev-workstation>

원격 주소와 마지막 커밋을 확인하는 명령:

```powershell
git remote -v
git log -1 --format="%H %cs %s"
git push -u origin main
```

마지막 확인된 커밋은 `5600415b4e9f818a088d6afb469284a4b2cddd09` (`2026-11-02`, `Complete dev workstation setup`)입니다. push 성공 여부는 GitHub 인증 완료 후 터미널의 실제 출력으로 확인하세요. Git 사용자 설정은 `git config --global --list`로 확인합니다. 인증 토큰이나 암호는 로그/스크린샷에 포함하지 않습니다.

## 참고 로그 및 스크린샷

- Docker 빌드와 이미지: [logs/docker-images.txt](logs/docker-images.txt)
- 컨테이너 목록: [logs/docker-ps-a.txt](logs/docker-ps-a.txt)
- Docker 정보와 버전: [logs/docker-info.txt](logs/docker-info.txt), [logs/docker-version.txt](logs/docker-version.txt)
- 웹 접속: [screenshots/port-access.png](screenshots/port-access.png)
- 바인드 마운트: [screenshots/bind-before.png](screenshots/bind-before.png), [screenshots/bind-after.png](screenshots/bind-after.png)
- 볼륨 검증: [screenshots/volume-proof.png](screenshots/volume-proof.png)
- GitHub 로그인: [screenshots/vscode-github-login.png](screenshots/vscode-github-login.png)
