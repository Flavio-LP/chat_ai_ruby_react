FROM node:22-alpine AS frontend-build
WORKDIR /app
COPY ../frontend/package*.json ./
RUN npm ci
COPY ../frontend .
RUN npm run build

FROM nginx:alpine
COPY --from=frontend-build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
