FROM nginx:alpine

RUN apk add --no-cache openssl

ARG PRIMARY_DOMAIN
ARG SECONDARY_DOMAIN
ARG TERTIARY_DOMAIN
ARG CERT_DIR=/etc/nginx/certs

ENV PRIMARY_DOMAIN=${PRIMARY_DOMAIN}
ENV SECONDARY_DOMAIN=${SECONDARY_DOMAIN}
ENV TERTIARY_DOMAIN=${TERTIARY_DOMAIN}
ENV CERT_DIR=${CERT_DIR}

RUN mkdir -p ${CERT_DIR} && \
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout ${CERT_DIR}/proxy.key \
    -out ${CERT_DIR}/proxy.crt \
    -subj "/CN=${PRIMARY_DOMAIN}/O=Local Lab/C=US" \
    -addext "subjectAltName=DNS:${PRIMARY_DOMAIN},DNS:${SECONDARY_DOMAIN},DNS:${TERTIARY_DOMAIN}"

COPY nginx.conf /etc/nginx/templates/default.conf.template

EXPOSE 80 443 2089

CMD ["nginx", "-g", "daemon off;"]
