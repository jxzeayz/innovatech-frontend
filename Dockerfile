# ── STAGE 1: Build ──────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar dependencias primero (caché de capas)
COPY package*.json ./
RUN npm ci --only=production=false

# Copiar código fuente y construir
COPY . .
RUN npm run build

# ── STAGE 2: Serve ──────────────────────────────
FROM nginx:alpine AS production

# Usuario no root para seguridad
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar build desde stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuración de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]