# ======== etap1 ========
FROM scratch as builder


# utworzenie warstwy bazowej obrazu 
ADD alpine-minirootfs-3.19.1-x86_64.tar /

# dodanie informacji o osobie tworzącej obraz
LABEL maintainer="Artsiom Patskevich"


# uaktualnienie systemu w warstwie bazowej oraz instalacja niezbędnych komponentów środowiska roboczego
RUN apk update && \
    apk upgrade && \
    apk add --no-cache nodejs=20.12.1-r0 \
    npm=10.2.5-r0 && \
    rm -rf /etc/apk/cache


# dodanie grupy i użytkownika 'node'
RUN addgroup -S node && \
    adduser -S node -G node

# ustawienie domyślnego użytkownika na 'node'
USER node

# ustawienie domyślnego katalogu roboczego
WORKDIR /home/node/app

# kopiowanie przygotowanej aplikacji
COPY --chown=node:node src/server.js ./server.js
COPY --chown=node:node src/package.json ./package.json
COPY --chown=node:node src/package-lock.json ./package-lock.json


# instalacja zaleności
RUN npm install

# ======== etap2 ========
FROM node:iron-alpine3.19

# dodanie informacji o osobie tworzącej obraz
LABEL maintainer="Artsiom Patskevich"

# ustawienie zmiennej wersji aplikacji z możliwością nadpisania
ARG VERSION
ENV VERSION=${VERSION:-v1.0.0}

# instalacja curl do sprawdzania stanu aplikacji
RUN apk add --update --no-cache curl

# ustawienie domyślnego użytkownika na 'node'
USER node

# utworzenie katalogu dla aplikacji
RUN mkdir -p /home/node/app

# ustawienie domyślnego katalogu roboczego
WORKDIR /home/node/app

# kopiowanie aplikacji i zależności z warstwy builder do produkcyjnego obrazu
COPY --from=builder --chown=server:server /home/node/app/server.js ./server.js
COPY --from=builder --chown=server:server /home/node/app/package.json ./package.json
COPY --from=builder --chown=server:server /home/node/app/package-lock.json ./package-lock.json
COPY --from=builder --chown=server:server /home/node/app/node_modules ./node_modules

# udostępnienie portu 3000 dla aplikacji
EXPOSE 3000

# konfiguracja sprawdzania stanu aplikacji z użyciem curl
HEALTHCHECK --interval=4s --timeout=20s --start-period=2s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# ustawienie domyślnego polecenia uruchomienia aplikacji
ENTRYPOINT ["node", "server.js"]
