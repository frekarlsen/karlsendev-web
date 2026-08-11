FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="karlsendev-web" \
      org.opencontainers.image.description="Nettsted for Karlsen Development" \
      org.opencontainers.image.url="https://karlsendev.no"

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/

RUN rm -f /usr/share/nginx/html/index.html.default

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
