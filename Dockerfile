# **********
# base stage
# **********
FROM node:20.9.0-alpine AS base

# 작업 디렉토리 설정
WORKDIR /app

# **********
# deps stage
# **********
FROM base AS deps

# 패키지 파일 복사
COPY package.json ./

# 잠금 파일 복사
COPY yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# 의존성 설치
RUN if [ -f "pnpm-lock.yaml" ]; then \
        npm install -g pnpm && \
        pnpm install; \
    elif [ -f "yarn.lock" ]; then \
        npm install -g yarn && \
        yarn install; \
    elif [ -f "package-lock.json" ]; then \
        npm install; \
    else \
        npm install; \
    fi

# NEXT.js Telemetry 비활성화
ENV NEXT_TELEMETRY_DISABLED 1

# ***********
# inter stage
# ***********
FROM deps AS inter

# 나머지 파일 복사
COPY . .

# 빌드 타임 환경 변수 설정
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# React 애플리케이션 빌드
RUN npm run build

# **********
# prod stage
# **********
FROM node:20.9.0-alpine AS prod

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 아티팩트 복사
COPY --from=inter /app/.next ./.next
COPY --from=inter /app/public ./public
COPY --from=inter /app/src ./src
COPY --from=inter /app/package.json ./package.json
COPY --from=inter /app/node_modules ./node_modules

# 포트 노출
EXPOSE 3000

# 애플리케이션 시작 명령어
CMD ["npm", "start"]
