ARG VERSION=latest
FROM tomsquest/docker-radicale:3.2.1.0

RUN /venv/bin/pip install git+https://github.com/Unrud/RadicaleInfCloud
