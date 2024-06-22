FROM python:3.9-slim

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r function/requirements.txt

ENV PORT 8080
CMD ["python", "index.py"]
