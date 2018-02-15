from python:3-alpine

run mkdir /app
workdir /app

run pip install pipenv

env PIPENV_VENV_IN_PROJECT true

copy ./Pipfile ./Pipfile
copy ./Pipfile.lock ./Pipfile.lock
copy ./.venv ./.venv

run pipenv install

env FLASK_APP /app/main.py
cmd flask run --host=0.0.0.0