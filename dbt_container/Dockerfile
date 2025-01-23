FROM python:3.9-slim-buster

WORKDIR /usr

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY profiles /usr/app/profiles

COPY profiles /root/.dbt/

RUN dbt deps

CMD ["dbt", "run", "--profiles-dir", "/app/profiles"]
