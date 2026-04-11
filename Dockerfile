FROM nginxinc/nginx-unprivileged:stable-alpine

# Become root for package install + system file writes
USER root
RUN apk add --no-cache tzdata \
  && cp /usr/share/zoneinfo/Europe/London /etc/localtime \
  && echo "Europe/London" > /etc/timezone \
  && apk del tzdata

# Use our nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy site files, set ownership to the unprivileged user
WORKDIR /usr/share/nginx/html
COPY --chown=101:101 . .

# Drop back to non-root for runtime
USER 101

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1
