FROM node:20.9.0-alpine

WORKDIR /usr/src/app

COPY package*.json ./
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD [ "node", "dist/main" ]