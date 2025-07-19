FROM python:3.9-slim
WORKDIR /usr/src/app
COPY index.html /usr/src/app/index.html
CMD ["python3", "-m", "http.server", "8080"]
EXPOSE 8080
