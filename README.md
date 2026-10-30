# 개발자용 '작업실' 꾸미기

## 1. 프로젝트 개요
터미널, Docker, Git/GitHub로 개발 환경을 직접 구성하고 각 단계를 검증한 기록입니다.
- 목표: (여기에 본인 말로 2~3줄 요약)

## 2. 실행 환경
| 항목 | 값 |
|---|---|
| OS | (Windows 버전: 10.0.26300.9711) |
| Shell / Terminal | (PowerShell / 명령프롬프트) |
| Docker | (Docker version 29.9.2, build a82e528) |
| Git | (git version 2.56.0.windows.4) |

## 3. 수행 체크리스트
- [ ] 터미널 기본 조작
- [ ] 권한 변경 실습
- [ ] Docker 설치/점검
- [ ] Docker 기본 운영 명령
- [ ] hello-world / ubuntu 실행
- [ ] Dockerfile 커스텀 이미지 빌드/실행
- [ ] 포트 매핑 접속
- [ ] 바인드 마운트 반영
- [ ] 볼륨 영속성
- [ ] Git 설정 + VSCode GitHub 연동

## 4. 터미널 조작 로그
```bash
$ pwd
$ ls -la
$ mkdir -p ~/codyssey/practice
$ cd ~/codyssey/practice
$ touch a.txt
$ echo "hello" > a.txt
$ cat a.txt
$ cp a.txt b.txt
$ mv b.txt c.txt
$ rm c.txt
# (각 명령 아래에 실제 출력 붙여넣기)
```

## 5. 권한 실습
```bash
# 파일
$ ls -l a.txt
$ chmod 600 a.txt
$ ls -l a.txt
# 디렉토리
$ ls -ld practice
$ chmod 755 practice
$ ls -ld practice
```
- 해석: 644 = 소유자 rw- / 그룹 r-- / 기타 r-- (r=4, w=2, x=1)

## 6. Docker 점검 및 운영
```bash
$ docker --version
$ docker info
$ docker images
$ docker ps -a
$ docker logs <컨테이너>
$ docker stats --no-stream
```

## 7. 컨테이너 실행 실습
```bash
$ docker run hello-world
$ docker run -it --name u1 ubuntu bash
root@...:/# ls
root@...:/# echo hi
```
**attach vs exec 관찰 메모:**
- `docker attach`: (관찰한 내용)
- `docker exec -it`: (관찰한 내용)

## 8. 커스텀 이미지 (Dockerfile)
- 선택한 베이스: `nginx:alpine` (방식 A)
- 커스텀 포인트와 목적:
  - LABEL: 이미지 식별
  - ENV: 실행 모드 표시
  - COPY: 기본 페이지 교체
  - HEALTHCHECK: 상태 자동 점검

```bash
$ docker build -t my-web:1.0 .
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ curl http://localhost:8080
```

## 9. 포트 매핑 증거
- 8080과 8081 두 포트로 각각 실행 (`-p 8081:80`)
- 스크린샷 (주소창에 포트 포함): `![8080](images/port-8080.png)`
- 포트 매핑이 필요한 이유: (본인 설명)

## 10. 바인드 마운트
```bash
$ docker run -d -p 8082:80 -v "$(pwd)/site":/usr/share/nginx/html --name bind-test nginx:alpine
$ curl http://localhost:8082        # 변경 전
$ echo "<h1>changed</h1>" > site/index.html
$ curl http://localhost:8082        # 변경 후
```

## 11. 볼륨 영속성
```bash
$ docker volume create mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test bash -c "echo hi > /data/hello.txt && cat /data/hello.txt"
$ docker rm -f vol-test
$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test2 cat /data/hello.txt     # 삭제 후에도 hi가 남아있는지 확인
```

## 12. Git 설정 및 GitHub 연동
```bash
$ git config --global user.name "이름"
$ git config --global user.email "이메일"
$ git config --global init.defaultBranch main
$ git config --list
```
- VSCode GitHub 로그인/저장소 연동 스크린샷: `![vscode](images/vscode-github.png)`
- Git(로컬 버전관리) vs GitHub(원격 협업 플랫폼): (본인 설명)

## 13. 트러블슈팅
### 사례 1
- 문제:
- 원인 가설:
- 확인:
- 해결/대안:

### 사례 2
- 문제:
- 원인 가설:
- 확인:
- 해결/대안:

## 14. 개념 정리
- 절대 경로 vs 상대 경로:
- 권한 r/w/x, 755/644:
- Docker 볼륨:

## 15. 재현 방법
```bash
git clone <저장소 주소>
cd <폴더>
docker build -t my-web:1.0 .
docker run -d -p 8080:80 my-web:1.0
```
> 민감정보(토큰, 비밀번호 등)는 모두 마스킹했습니다.
