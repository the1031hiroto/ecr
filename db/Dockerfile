FROM postgres:13.2-alpine

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=pass
ENV POSTGRES_DB=dev
ENV TZ="Asia/Tokyo"

# VOLUME ./docker/db/postgres/data:/var/lib/postgresql/data

EXPOSE 5432

HEALTHCHECK --interval=5s --timeout=3s CMD pg_isready -d dev -U postgres || exit 1
