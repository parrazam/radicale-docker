ARG VERSION=latest
FROM tomsquest/docker-radicale:3.1.9.1

RUN /venv/bin/pip install git+https://github.com/Unrud/RadicaleInfCloud
