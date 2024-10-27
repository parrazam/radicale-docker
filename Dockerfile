ARG VERSION=latest
FROM tomsquest/docker-radicale:3.3.0.1

RUN /venv/bin/pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud
