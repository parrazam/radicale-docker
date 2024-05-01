ARG VERSION=latest
FROM tomsquest/docker-radicale:3.1.9.1

RUN python3 -m pip install --upgrade https://github.com/Unrud/RadicaleInfCloud/archive/master.tar.gz
COPY config.js /usr/lib/python3.7/site-packages/radicale_infcloud/web/config.js
