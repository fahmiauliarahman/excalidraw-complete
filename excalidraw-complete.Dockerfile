# Build stage for UI
FROM node:18-alpine AS ui-builder
WORKDIR /home/node/app
COPY excalidraw/package*.json ./
COPY excalidraw/excalidraw-app/package*.json ./excalidraw-app/
COPY excalidraw/packages/excalidraw/package*.json ./packages/excalidraw/
COPY excalidraw/yarn.lock ./
RUN npm install -g cross-env
RUN yarn install
COPY excalidraw/ ./
WORKDIR /home/node/app/excalidraw-app
RUN NODE_OPTIONS="--max-old-space-size=4096" yarn build:app:docker

# Then build the Go backend
FROM golang:1.21-alpine AS builder
RUN apk update && apk add --no-cache git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Copy the frontend build from the ui-builder stage
COPY --from=ui-builder /home/node/app/excalidraw-app/build ./frontend
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Final image
FROM alpine
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/.env .
COPY --from=builder /app/frontend ./frontend
EXPOSE 3002
CMD ["./main"]
