FROM node:22-alpine

WORKDIR /app

COPY server/package*.json ./
RUN npm ci --omit=dev

COPY server/src ./src
COPY server/sql ./sql
RUN mkdir -p uploads

EXPOSE 4000
CMD ["npm", "start"]
