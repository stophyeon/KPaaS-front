FROM node:20.9.0-alpine AS base

WORKDIR /app

FROM base AS deps

COPY package.json ./

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

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

ENV NEXT_TELEMETRY_DISABLED 1

FROM deps AS inter

COPY . .

EXPOSE 3000

FROM inter AS prod

RUN npm run build

FROM inter AS dev

CMD ["npm", "start"]