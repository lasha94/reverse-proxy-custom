FROM nginx:alpine

RUN apk add --no-cache openssl

# Coolify-დან მისაღები Build Argument-ები (ნაგულისხმევი მნიშვნელობების გარეშე)
ARG PRIMARY_DOMAIN
ARG SECONDARY_DOMAIN
ARG CERT_DIR=/etc/nginx/certs

# გადავცემთ ENV-ში, რომ Nginx-ის შაბლონმა runtime-ზე წაიკითხოს
ENV PRIMARY_DOMAIN=${PRIMARY_DOMAIN}
ENV SECONDARY_DOMAIN=${SECONDARY_DOMAIN}

# SSL სერტიფიკატის გენერაცია build პროცესში
RUN mkdir -p ${CERT_DIR} && \
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout ${CERT_DIR}/proxy.key \
    -out ${CERT_DIR}/proxy.crt \
    -subj "/CN=${PRIMARY_DOMAIN}/O=Local Lab/C=US" \
    -addext "subjectAltName=DNS:${PRIMARY_DOMAIN},DNS:${SECONDARY_DOMAIN}"

# Nginx-ის შაბლონის კოპირება (envsubst ავტომატურად ჩაანაცვლებს ცვლადებს)
COPY nginx.conf /etc/nginx/templates/nginx.conf.template

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]