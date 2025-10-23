ARG VERSION=latest
FROM tomsquest/docker-radicale:3.5.7.0

RUN /venv/bin/pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud
