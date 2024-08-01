# **********
# base stage
# **********
FROM node:20.9.0-alpine AS base

# 작업 디렉토리 설정
WORKDIR /usr/src/app

# **********
# deps stage
# **********
FROM base AS deps

# 패키지 파일 복사
COPY package.json ./

# NEXT.js Telemetry 비활성화
ENV NEXT_TELEMETRY_DISABLED 1

# 빌드 타임 환경 변수 설정
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# React 애플리케이션 빌드
COPY package*.json ./
RUN npm install

# Copy app source code
COPY . .

# Build the app
RUN npm run build

# Expose the port the app runs on
EXPOSE 3000

RUN next build

# Command to run the app
CMD ["next", "start"]
