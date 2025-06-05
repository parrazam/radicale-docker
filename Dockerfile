ARG VERSION=latest
FROM tomsquest/docker-radicale:3.5.4.0

RUN /venv/bin/pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud
