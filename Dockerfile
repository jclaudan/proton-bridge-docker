FROM golang:1.21-bookworm AS binary

WORKDIR /usr/src/app

COPY fakeauth .

RUN go build -v -o /usr/local/bin/fakeauth fakeauth

FROM nginx:bookworm

LABEL org.opencontainers.image.source="https://github.com/jclaudan/proton-bridge-docker" \
      org.opencontainers.image.title="Proton Mail Bridge" \
      org.opencontainers.image.desctiption="Docker image to run Proton Mail Bridge" \
      org.opencontainers.image.authors="jclaudan"

WORKDIR /protonmail

COPY gpgparams install.sh VERSION ./

RUN bash install.sh

COPY --from=binary /usr/local/bin/fakeauth /usr/local/bin/fakeauth

RUN apt-get update
RUN apt-get install -y gnome-keyring
RUN apt-get install -y dbus-x11

EXPOSE 25/tcp
EXPOSE 143/tcp
COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh .

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
