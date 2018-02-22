FROM python:3-alpine

RUN mkdir /app
WORKDIR /app

RUN pip install pipenv

ENV PIPENV_VENV_IN_PROJECT true

COPY ./Pipfile ./Pipfile
COPY ./Pipfile.lock ./Pipfile.lock

RUN pipenv install --system

COPY . .

ENV FLASK_APP /app/main.py
CMD flask run --host=0.0.0.0