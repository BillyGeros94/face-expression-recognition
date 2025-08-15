# Dockerfile for Plumber API
FROM rocker/r-ver:4.4.1

# Install minimal system libs needed to compile R packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libcurl4-openssl-dev \
      libxml2-dev \
      libssl-dev \
      libxt-dev \
      libglpk-dev && \
    rm -rf /var/lib/apt/lists/*

# Install R packages (plumber + caret + kknn)
RUN R -e "install.packages(c('plumber', 'caret', 'kknn'))"

# Create working dir for the API and artifact path expected by api.R
WORKDIR /app
RUN mkdir -p /artifacts/models

# Copy API source
COPY /api/api.R /app/api.R

# Copy model and metadata from your repo into the image.
# IMPORTANT: Build from project root so these paths exist in build context.
COPY artifacts/models/knn_raw.rds  /artifacts/models/knn_raw.rds
COPY artifacts/models/metadata.rds /artifacts/models/metadata.rds

EXPOSE 8000

# Start the plumber API
CMD ["Rscript", "-e", "library(plumber); pr <- plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]