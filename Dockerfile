FROM tomsquest/docker-radicale:latest

RUN python3 -m pip install git+https://github.com/Unrud/RadicaleInfCloud
COPY config.js /usr/lib/python3.7/site-packages/radicale_infcloud/web/config.js
