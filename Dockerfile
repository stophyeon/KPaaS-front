# **********
# base stage
# **********
FROM node:20.9.0-alpine AS base

WORKDIR /app

# **********
# deps stage
# **********
FROM base AS deps

# Copy package.json to /app
COPY package.json ./

# Copy available lock file
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies according to the lockfile
RUN if [ -f "pnpm-lock.yaml" ]; then \
        npm install -g pnpm && \
        pnpm install; \
    elif [ -f "yarn.lock" ]; then \
        npm install -g yarn && \
        yarn install; \
    elif [ -f "package-lock.json" ];then \
        npm install; \
    else \
        npm install; \
        # If you want to throw error on lockfile not being available, 
        # uncomment the following lines
        # echo "No Lockfile!"; \
        # exit 1; \
    fi

# Disable the telemetry
ENV NEXT_TELEMETRY_DISABLED 1

# ***********
# inter stage
# ***********
FROM deps AS inter

# Copy all other files excluding the ones in .dockerignore
COPY . .

# Set build-time environment variables
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# Build the React application
RUN npm run build

# **********
# prod stage
# **********
FROM node:20.9.0-alpine AS prod

WORKDIR /app

# Copy the build output from the inter stage
COPY --from=inter /app/.next ./.next
COPY --from=inter /app/public ./public
COPY --from=inter /app/package.json ./package.json
COPY --from=inter /app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "start"]
