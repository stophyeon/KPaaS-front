# **********
# base stage
# **********
FROM --platform=linux/amd64/v3 node:20.9.0-alpine AS base

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
# build stage
# ***********
FROM deps AS build

# Copy all other files excluding the ones in .dockerignore
COPY . .

# Set build-time environment variables
ARG NEXT_PUBLIC_API_URL=http://192.168.23.73:31663
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# Build the React application
RUN npm run build

# **********
# prod stage
# **********
FROM base AS prod

# Copy built files from build stage
COPY --from=build /app/.next /app/.next
COPY --from=build /app/public /app/public
COPY --from=build /app/package.json /app/package.json

# Install only production dependencies
RUN npm install --production

# Exposing the port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
