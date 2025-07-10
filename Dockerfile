FROM ubuntu:latest
WORKDIR /app
COPY index.html .
RUN apt-get update && apt-get install -y python3
CMD ["python3", "-m", "http.server", "80"]
