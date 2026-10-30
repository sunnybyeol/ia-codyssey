# (A) 웹 서버 베이스 이미지 활용: nginx + 정적 콘텐츠 교체
FROM nginx:alpine

# 커스텀 포인트 1: 이미지 메타데이터 (누가 만든 이미지인지 식별)
LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL org.opencontainers.image.authors="sunnybyeol"

# 커스텀 포인트 2: 환경변수 (실행 모드 표시용)
ENV APP_ENV=dev

# 커스텀 포인트 3: 기본 페이지를 내 페이지로 교체
COPY site/ /usr/share/nginx/html/

# 커스텀 포인트 4: 헬스체크 (서버가 살아있는지 주기적으로 확인)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1

EXPOSE 80
