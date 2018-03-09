FROM python:3-alpine

RUN mkdir /app
WORKDIR /app

# ENV PIPENV_VENV_IN_PROJECT true

# RUN pip install pipenv

# COPY ./Pipfile ./Pipfile
# COPY ./Pipfile.lock ./Pipfile.lock

# RUN pipenv install --system

COPY ./requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

COPY . .

ENV FLASK_APP /app/main.py
CMD flask run --host=0.0.0.0