FROM nginx:alpine

RUN apk add --no-cache openssl

# Coolify-დან მისაღები Build Argument-ები (დავამატეთ მესამე დომენი auth.cpanel.net-ისთვის)
ARG PRIMARY_DOMAIN
ARG SECONDARY_DOMAIN
ARG TERTIARY_DOMAIN
ARG CERT_DIR=/etc/nginx/certs

# გადავცემთ ENV-ში, რომ Nginx-ის შაბლონმა runtime-ზე წაიკითხოს
ENV PRIMARY_DOMAIN=${PRIMARY_DOMAIN}
ENV SECONDARY_DOMAIN=${SECONDARY_DOMAIN}
ENV TERTIARY_DOMAIN=${TERTIARY_DOMAIN}
ENV CERT_DIR=${CERT_DIR}

# SSL სერტიფიკატის გენერაცია build პროცესში სამივე დომენისთვის (SAN)
RUN mkdir -p ${CERT_DIR} && \
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout ${CERT_DIR}/proxy.key \
    -out ${CERT_DIR}/proxy.crt \
    -subj "/CN=${PRIMARY_DOMAIN}/O=Local Lab/C=US" \
    -addext "subjectAltName=DNS:${PRIMARY_DOMAIN},DNS:${SECONDARY_DOMAIN},DNS:${TERTIARY_DOMAIN}"

# მნიშვნელოვანი: შაბლონს ვინახავთ როგორც default.conf.template
# Nginx მას ავტომატურად გარდაქმნის /etc/nginx/conf.d/default.conf ფაილად
COPY nginx.conf /etc/nginx/templates/default.conf.template

# ვხსნით სამივე საჭირო პორტს (მათ შორის cPanel-ის 2089-ს)
EXPOSE 80 443 2089

CMD ["nginx", "-g", "daemon off;"]
